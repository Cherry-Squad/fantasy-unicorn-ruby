# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Override controller to set field email_validated -> true
      class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
        def show
          @user = resource_class.confirm_by_token(params[:confirmation_token])

          raise ActionController::RoutingError, 'Not Found' unless @user&.id

          # create client id
          client_id  = SecureRandom.urlsafe_base64(nil, false)
          token      = SecureRandom.urlsafe_base64(nil, false)
          token_hash = BCrypt::Password.create(token)
          expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

          @user.tokens[client_id] = {
            token: token_hash,
            expiry: expiry
          }
          @user.email_validated = true

          @user.save!

          redirect_to(@user.build_auth_url(params[:redirect_url], {
                                             token: token,
                                             client_id: client_id,
                                             account_confirmation_success: true,
                                             config: params[:config]
                                           }))
        end
      end
    end
  end
end
