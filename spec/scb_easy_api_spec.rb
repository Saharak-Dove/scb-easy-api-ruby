require 'scb_easy_api'
require 'webmock/rspec'

WebMock.allow_net_connect!

describe ScbEasyApi::Client do
  $HOST = "https://api-sandbox.partners.scb"
  $OAUTH_PATH = "/partners/sandbox/v1/oauth/token"
  $DEEPLINK_TRANSATIONS_PATH = "/partners/sandbox/v3/deeplink/transactions"
  $QRCODE_PAYMENT_PATH = "/partners/sandbox/v1/payment/qrcode/create"

  def dummy_config
    {
      api_key: 'l72f8c215460ac4c2ea72702c3a48b5c62',
      api_secret: '01a3c4687d6a4f93a44e90d33911ba67',
      biller_id: '632784896647804',
      merchant_id: '790464285535354',
      terminal_id: '083028403369375',
      reference_prefix: 'GXZ',
      accept_language: 'EN',
    }
  end

  def generate_client
    ScbEasyApi::Client.new do |config|
      config.api_key = dummy_config[:api_key]
      config.api_secret = dummy_config[:api_secret]
      config.biller_id = dummy_config[:biller_id]
      config.merchant_id = dummy_config[:merchant_id]
      config.terminal_id = dummy_config[:terminal_id]
      config.reference_prefix = dummy_config[:reference_prefix]
      config.accept_language = dummy_config[:accept_language]
    end
  end

  it 'create oauth access token' do
    client = generate_client
    response = client.oauth_token
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Success')
  end

  it 'create paymemnt transactions' do
    client = generate_client
    response = client.create_paymemnt(2000)
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Deeplink successfully created')
  end

  it 'create QR Code paymemnt' do
    client = generate_client
    response = client.create_qrcode_paymemnt(2000)
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Success')
  end
end  