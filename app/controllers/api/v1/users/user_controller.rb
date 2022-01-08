# frozen_string_literal: true

module Api
  module V1
    module Users
      # UserController class
      class UserController < ApplicationController
        before_action :authenticate_api_v1_user!

        def index
          users = User.all
          render json: users, status: 200
        end

        def update
          user = current_user
          if user.update(user_update_params)
            render json: user, status: 201
          else
            render json: { error: "An Error occurred #{user.errors.full_messages}" }, status: 400
          end
        rescue StandardError => e
          render json: { error: "An Error occurred #{e.message}" }, status: 400
        end

        def show
          user = user_by_id
          if user
            render json: user, status: 200
          else
            render status: 404
          end
        end

        def scoreboard
          users = User.where('fantasy_points > 0').order('fantasy_points DESC')
          render json: users, status: 200
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

        def user_by_id
          User.find_by(id: params[:id])
        end

        def current_user
          User.find_by(id: current_api_v1_user.id)
        end
      end
    end
  end
end
