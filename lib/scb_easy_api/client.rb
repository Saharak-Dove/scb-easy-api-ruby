require 'rest-client'
require 'securerandom'

module ScbEasyApi
  # API Client of SCB easy Ruby
  #
  #   @client ||= ScbEasyApi::Client.new do |config|
  #      config.api_key = ENV["scb_api_key"]
  #      config.api_secret = ENV["scb_api_secret"]
  #      config.biller_id = ENV["scb_biller_id"]
  #      config.merchant_id = ENV["scb_merchant_id"]
  #      config.terminal_id = ENV["scb_terminal_id"]
  #      config.reference_prefix = ENV["scb_reference_prefix"]
  #      config.accept_language = ENV["scb_accept_language"] || 'EN'
  #   end
  
  class Client
    $HOST = "https://api-sandbox.partners.scb"
    $OAUTH_PATH = "/partners/sandbox/v1/oauth/token"
    $DEEPLINK_TRANSATIONS_PATH = "/partners/sandbox/v3/deeplink/transactions"
    $QRCODE_PAYMENT_PATH = "/partners/sandbox/v1/payment/qrcode/create"
    #  @return [String]
    attr_accessor :api_key, :api_secret, :biller_id, :merchant_id, :terminal_id, :reference_prefix, :accept_language

    # Initialize a new client.
    #
    # @param options [Hash]
    # @return [ScbEasyApi::Client]
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      yield(self) if block_given?
    end

    def rest_client_api(url, method, headers, payload)
      response = RestClient::Request.new({
        url: url,
        method: method.to_sym,
        headers: headers,
        payload: payload.to_json
      }).execute do |response, request, result|
        return JSON.parse(response.to_str)
      end
    end

    def headers_with_bearer
      api_key_required

      {
        Authorization: "Bearer #{oauth_token['data']['accessToken']}",
        content_type: 'application/json', 
        resourceOwnerId: api_key,
        requestUId: SecureRandom.uuid,
        channel: 'scbeasy',
        accept_language: accept_language || 'EN'
      }
    end  

    def oauth_token
      api_key_required

      rest_client_api("#{$HOST}#{$OAUTH_PATH}", "post", {
        content_type: 'application/json', 
        resourceOwnerId: api_key,
        requestUId: SecureRandom.uuid,
        accept_language: 'EN'
      }, payload_token)
    end

    def create_paymemnt(payment_amount)
      rest_client_api("#{$HOST}#{$DEEPLINK_TRANSATIONS_PATH}", "post", headers_with_bearer, payload_transactions(payment_amount))
    end

    def create_qrcode_paymemnt(payment_amount)
      rest_client_api("#{$HOST}#{$QRCODE_PAYMENT_PATH}", "post", headers_with_bearer, payload_qrcode_payment(payment_amount))
    end

    def payload_token(authorization_code = nil)
      api_key_required
      api_secret_required

      {
        applicationKey: api_key,
        applicationSecret: api_secret,
        authCode: authorization_code
      }
    end

    def payload_transactions(payment_amount)
      biller_id_required
      merchant_id_required
      terminal_id_required
      reference_prefix_required

      {
        transactionType: "PURCHASE",
        transactionSubType: ["BP", "CCFA"],
        sessionValidityPeriod: 60,
        sesisionValidUntil: "",
        billPayment: {
          paymentAmount: payment_amount,
          accountTo: biller_id,
          ref1: "#{reference_prefix}#{rand(1000000..999999999)}",
          ref2: "#{reference_prefix}#{rand(1000000..999999999)}",
          ref3: reference_prefix
        },
        creditCardFullAmount: {
          merchantId: merchant_id,
          terminalId: terminal_id,
          orderReference: reference_prefix,
          paymentAmount: payment_amount
        },
        merchantMetaData: {
          callbackUrl: "",
          extraData: {},
          paymentInfo: [
            {
              type: "TEXT_WITH_IMAGE",
              title: "",
              header: "",
              description: "",
              imageUrl: ""
            },
            {
              type: "TEXT",
              title: "",
              header: "",
              description: ""
            }
          ]
        }
      }
    end

    def payload_qrcode_payment(amount)
      biller_id_required
      merchant_id_required
      terminal_id_required
      reference_prefix_required

      {
        qrType: "PPCS",
        ppType: "BILLERID",
        ppId: biller_id,
        amount: amount,
          ref1: "#{reference_prefix}#{rand(1000000..999999999)}",
          ref2: "#{reference_prefix}#{rand(1000000..999999999)}",
          ref3: "SCB",
        merchantId: merchant_id,
        terminalId: terminal_id,
        invoice: "INVOICE",
        csExtExpiryTime: "60"
      }
    end

    private

    def api_key_required
      raise ArgumentError, '`api_key` is not configured' unless api_key
    end

    def api_secret_required
      raise ArgumentError, '`api_secret` is not configured' unless api_secret
    end

    def biller_id_required
      raise ArgumentError, '`biller_id` is not configured' unless biller_id
    end

    def merchant_id_required
      raise ArgumentError, '`merchant_id` is not configured' unless merchant_id
    end

    def terminal_id_required
      raise ArgumentError, '`terminal_id` is not configured' unless terminal_id
    end

    def reference_prefix_required
      raise ArgumentError, '`reference_prefix` is not configured' unless reference_prefix
    end
  end
end
