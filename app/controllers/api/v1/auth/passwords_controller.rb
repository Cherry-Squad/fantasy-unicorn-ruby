# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Not to show users that there is no such email in the database
      class PasswordsController < DeviseTokenAuth::PasswordsController
        def create
          return render_create_error_missing_email unless resource_params[:email]

          @email = get_case_insensitive_field_from_resource_params(:email)
          @resource = find_resource(:uid, @email)

          if @resource
            yield @resource if block_given?
            @resource.send_reset_password_instructions(
              email: @email,
              provider: 'email',
              redirect_url: @redirect_url,
              client_config: params[:config_name]
            )

            if @resource.errors.empty?
              render_create_success
            else
              render_create_error @resource.errors
            end
          else
            render_create_success
          end
        end
      end
    end
  end
end
