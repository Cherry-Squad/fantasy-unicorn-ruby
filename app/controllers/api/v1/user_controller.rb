
module Api
  module V1
    class UserController < ApplicationController
    before_action :authenticate_api_v1_user!

    def index
      users = User.all
      render json: users, status: 200
    end

    def update
      begin
        user = get_current_user
        if user
          if user.update(user_update_params)
            render json: user, status: 201
          else
            render json: {error: "An Error occurred #{user.errors.full_messages}"}, status: 400
          end
        else
          render json: {error: "An error occurred #{user.errors.full_messages}"}, status: 404
        end
      rescue => error
        render json: {error: "An Error occurred #{error.message}"}, status: 400
      end
    end

    def show
      user = get_user_by_id
      if user
        render json: user, status: 200
      else
        render status: 404
      end
    end
    private

    def user_update_params
      params.permit([
                      current_api_v1_user.id,
                      :username,
                      :email,
                      :preferred_lang,
                      :fantasy_points,
                      :coins
                    ])
    end

    def get_user_by_id
      User.find_by(id: params[:id])
    end

    def get_current_user
      User.find_by(id: current_api_v1_user.id)
    end
  end
  end
end
