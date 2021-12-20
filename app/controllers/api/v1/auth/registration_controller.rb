# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Adds username as required parameter for registration and update
      class RegistrationController < DeviseTokenAuth::RegistrationsController
        before_action :configure_permitted_parameters
        wrap_parameters format: []

        protected

        def configure_permitted_parameters
          devise_parameter_sanitizer.permit(:sign_up, keys: %i[username])
          devise_parameter_sanitizer.permit(:account_update, keys: %i[username])
        end
      end
    end
  end
end
