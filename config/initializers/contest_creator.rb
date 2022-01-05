# frozen_string_literal: true

Rails.application.configure do
  config.divisions = ActiveSupport::OrderedOptions.new
  config.divisions = Rails.application.config_for :divisions
end
