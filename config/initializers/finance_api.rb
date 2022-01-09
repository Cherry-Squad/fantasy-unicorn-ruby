# frozen_string_literal: true

require 'finnhub_ruby'

Rails.application.configure do
  config.finnhub_config = (Rails.application.config_for :finance_api)['finnhub']
  FinnhubRuby.configure.api_key['api_key'] = config.finnhub_config[:api_key] if config.finnhub_config[:enable]

  config.time_shift = config.finnhub_config[:time_shift]
end
