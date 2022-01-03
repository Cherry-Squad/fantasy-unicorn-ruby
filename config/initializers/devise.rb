# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = 'no-reply@gmail.com'
  config.reconfirmable = false
end
