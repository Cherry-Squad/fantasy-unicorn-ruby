# frozen_string_literal: true

module Api
  module V1
    module Users
      # ContestApplicationController class
      class ContestApplicationController < ApplicationController
        before_action :authenticate_api_v1_user!

        def show
          contest_application = contest_applications_by_id
          if contest_application
            render json: contest_application, status: 200
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        private

        def contest_applications_by_id
          ContestApplication.find_by(id: params[:id], user: current_api_v1_user)
        end
      end
    end
  end
end
