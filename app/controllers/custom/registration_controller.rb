class Custom::RegistrationController < DeviseTokenAuth::RegistrationsController
    before_action :configure_permitted_parameters
  
    protected
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: %i(username))
      devise_parameter_sanitizer.permit(:account_update, keys: %i(username))
    end
  end