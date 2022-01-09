# frozen_string_literal: true

require 'finnhub_ruby'

FINANCE_API_CONFIG = YAML.safe_load(
  ERB.new(File.read(Rails.root.join('config/finance_api.yml'))).result, aliases: true
)[Rails.env]
finnhub_config = FINANCE_API_CONFIG['finnhub']

if finnhub_config['enable']
  FinnhubRuby.configure do |config|
    config.api_key['api_key'] = finnhub_config['api_key']
  end
end

Rails.configuration.time_shift = 0
Rails.configuration.time_shift = -4.days.to_i if Rails.env.test?
