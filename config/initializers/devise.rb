# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = Rails.application.credentials.email
  config.reconfirmable = false
end
