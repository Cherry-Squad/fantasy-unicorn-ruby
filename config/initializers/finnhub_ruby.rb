# frozen_string_literal: true

require 'finnhub_ruby'

if Settings.finance_api.finnhub.enable
  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = Settings.finance_api.finnhub.api_key
  end
end
