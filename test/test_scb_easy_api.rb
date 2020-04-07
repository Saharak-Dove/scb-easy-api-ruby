require 'minitest/autorun'
require 'scb_easy_api'

class ScbEasyApiTest < Minitest::Test
  def test_client
    @client ||= ScbEasyApi::Client.new do |config|
      config.api_key = 'l72f8c215460ac4c2ea72702c3a48b5c62'
      config.api_secret = '01a3c4687d6a4f93a44e90d33911ba67'
      config.biller_id = '632784896647804'
      config.merchant_id = '790464285535354'
      config.terminal_id = '083028403369375'
      config.reference_prefix = 'GXZ'
    end

    assert_equal(@client.api_key, 'l72f8c215460ac4c2ea72702c3a48b5c62')
  end
end