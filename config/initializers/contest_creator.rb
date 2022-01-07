# frozen_string_literal: true

Rails.application.configure do
  config.divisions = Rails.application.config_for :divisions
  config.contests_generating = Rails.application.config_for :contests_generating
end
