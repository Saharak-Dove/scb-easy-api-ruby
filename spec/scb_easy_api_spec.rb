require 'scb_easy_api'
require 'webmock/rspec'

WebMock.allow_net_connect!

describe ScbEasyApi::Client do
  def dummy_config
    {
      api_key: 'l72f8c215460ac4c2ea72702c3a48b5c62',
      api_secret: '01a3c4687d6a4f93a44e90d33911ba67',
      biller_id: '632784896647804',
      merchant_id: '790464285535354',
      terminal_id: '083028403369375',
      reference_prefix: 'GXZ',
      language: 'EN',
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
      config.language = dummy_config[:language]
    end
  end

  it 'Create oauth access token' do
    client = generate_client
    response = client.oauth_token
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Success')
  end

  it 'Create paymemnt transactions' do
    client = generate_client
    response = client.create_paymemnt(2000)
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Deeplink successfully created')
  end

  it 'Create QR Code paymemnt' do
    client = generate_client
    response = client.create_qrcode_paymemnt(2000)
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Success')
  end

  it 'Create QR Code paymemnt for Alipay' do
    client = generate_client
    response = client.create_qrcode_alipay('001', 5000)
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Success')
  end

  it 'Create QR Code paymemnt for WeChat pay' do
    client = generate_client
    response = client.create_qrcode_we_chat_pay('001', 10000)
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Success')
  end

  it 'Pay with for Alipay' do
    client = generate_client
    response = client.pay_with_alipay('001', 5000, 1234567890)
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Success')
  end

  it 'Pay with WeChat pay' do
    client = generate_client
    response = client.pay_with_we_chat_pay('001', 10000, 1234567890)
    
    expect(response['status']['code']).to eq(1000)
    expect(response['status']['description']).to eq('Success')
  end
end