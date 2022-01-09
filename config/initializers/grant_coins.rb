# frozen_string_literal: true

Rails.application.configure do
  config.rolling_coins = Rails.application.config_for :rolling_coins
end
