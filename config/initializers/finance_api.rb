# frozen_string_literal: true

require 'finnhub_ruby'

Rails.application.configure do
  config.finnhub_config = (Rails.application.config_for :finance_api)['finnhub']
  if config.finnhub_config[:enable]
    FinnhubRuby.configure.api_key['api_key'] = config.finnhub_config[:api_key]
  end

  config.time_shift = 0
  config.time_shift = -4.days.to_i if Rails.env.test?
end
