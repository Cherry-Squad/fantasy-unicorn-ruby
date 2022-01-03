# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

CONFIG = YAML.safe_load(
  ERB.new(File.read(Rails.root.join('config/cors.yml'))).result, aliases: true
)[Rails.env]
origins_from_config = CONFIG['origins']

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins origins_from_config

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: %w[access-token uid expiry client]
  end
end
