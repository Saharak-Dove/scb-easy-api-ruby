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
  #      config.language = ENV["scb_language"] || 'EN'
  #      config.is_sandbox = ENV["scb_is_sandbox"] || true
  #   end
  
  class Client
    $OAUTH_PATH = "v1/oauth/token"
    $DEEPLINK_TRANSATIONS_PATH = "v3/deeplink/transactions"
    $QRCODE_PAYMENT_PATH = "v1/payment/qrcode/create"
    $PAYMENT_CONFIRM_PATH = "v1/payment/merchant/rtp/confirm"
    $PAYMENT_EWALLETS_CREATE_PATH​ = "v1/payment/ewallets/qrcode/create"
    $PAYMENT_EWALLETS_CANCEL_PATH​ = "v1/payment/ewallets/cancel"
    $PAYMENT_EWALLETS_PAY_PATH​ = "v1/payment/ewallets/pay"

    #  @return [String]
    attr_accessor :api_key, :api_secret, :biller_id, :merchant_id, :terminal_id, :reference_prefix, :language, :is_sandbox

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

    def endpoint
      if is_sandbox.nil? || is_sandbox == true
        @endpoint = "https://api-sandbox.partners.scb/partners/sandbox/"
      else
        @endpoint = "https://api.partners.scb/partners/"
      end
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

    def headers
      api_key_required

      {
        Authorization: "Bearer #{oauth_token['data']['accessToken']}",
        content_type: 'application/json', 
        resourceOwnerId: api_key,
        requestUId: SecureRandom.uuid,
        channel: 'scbeasy',
        accept_language: language || 'EN'
      }
    end  

    def oauth_token
      api_key_required

      rest_client_api("#{endpoint}#{$OAUTH_PATH}", "post", {
        content_type: 'application/json', 
        resourceOwnerId: api_key,
        requestUId: SecureRandom.uuid,
        accept_language: language || 'EN'
      }, payload_token)
    end

    def create_paymemnt(amount)
      rest_client_api("#{endpoint}#{$DEEPLINK_TRANSATIONS_PATH}", "post", headers, payload_transactions(amount))
    end

    def create_qrcode_paymemnt(amount)
      rest_client_api("#{endpoint}#{$QRCODE_PAYMENT_PATH}", "post", headers, payload_qrcode_payment(amount))
    end

    def create_qrcode_alipay(company_id, amount)
      payload = payload_qrcode_ewallets(true, company_id, amount)
      resp = rest_client_api("#{endpoint}#{$PAYMENT_EWALLETS_CREATE_PATH​}", "post", headers, payload)
      resp['outTradeNo'] = payload[:outTradeNo]

      resp
    end

    def create_qrcode_we_chat_pay(company_id, amount)
      payload = payload_qrcode_ewallets(false, company_id, amount)
      resp = rest_client_api("#{endpoint}#{$PAYMENT_EWALLETS_CREATE_PATH​}", "post", headers, payload)
      resp['outTradeNo'] = payload[:outTradeNo]

      resp
    end

    def cancel_payment_alipay(company_id, out_trade_no)
      payload = payload_cancel_ewallets(true, company_id, out_trade_no)
      rest_client_api("#{endpoint}#{$PAYMENT_EWALLETS_CANCEL_PATH​}", "post", headers, payload)
    end

    def cancel_payment_we_chat_pay(company_id, out_trade_no)
      payload = payload_cancel_ewallets(false, company_id, out_trade_no)
      rest_client_api("#{endpoint}#{$PAYMENT_EWALLETS_CANCEL_PATH​}", "post", headers, payload)
    end

    def pay_with_alipay(company_id, amount, buyer_identity_code)
      payload = payload_ewallets_pay(true, company_id, amount, buyer_identity_code)
      resp = rest_client_api("#{endpoint}#{$PAYMENT_EWALLETS_CREATE_PATH​}", "post", headers, payload)
      resp['outTradeNo'] = payload[:outTradeNo]

      resp
    end

    def pay_with_we_chat_pay(company_id, amount, buyer_identity_code)
      payload = payload_ewallets_pay(false, company_id, amount, buyer_identity_code)
      resp = rest_client_api("#{endpoint}#{$PAYMENT_EWALLETS_CREATE_PATH​}", "post", headers, payload)
      resp['outTradeNo'] = payload[:outTradeNo]

      resp
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

    def payload_transactions(amount)
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
          paymentAmount: amount,
          accountTo: biller_id,
          ref1: "#{reference_prefix}#{rand(1000000..999999999)}",
          ref2: "#{reference_prefix}#{rand(1000000..999999999)}",
          ref3: reference_prefix
        },
        creditCardFullAmount: {
          merchantId: merchant_id,
          terminalId: terminal_id,
          orderReference: reference_prefix,
          paymentAmount: amount
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

    def payload_qrcode_ewallets(is_alipay, company_id, amount)
      terminal_id_required
      reference_prefix_required

      {
        tranType: is_alipay ? 'A' : 'W',
        companyId: company_id,
        terminalId: terminal_id,
        outTradeNo: "SCB#{rand(1000000..999999999)}",
        totalFee: amount
      }
    end

    def payload_cancel_ewallets(is_alipay, company_id, out_trade_no)
      terminal_id_required
      reference_prefix_required

      {
        tranType: is_alipay ? 'A' : 'W',
        companyId: company_id,
        terminalId: terminal_id,
        outTradeNo: out_trade_no
      }
    end

    def payload_ewallets_pay(is_alipay, company_id, amount, buyer_identity_code)
      terminal_id_required
      reference_prefix_required

      {
        tranType: is_alipay ? 'A' : 'W',
        companyId: company_id,
        terminalId: terminal_id,
        outTradeNo: "SCB#{rand(1000000..999999999)}",
        totalFee: amount,
        buyerIdentityCode: buyer_identity_code
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
