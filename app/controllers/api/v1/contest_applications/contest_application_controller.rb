# frozen_string_literal: true

module Api
  module V1
    module ContestApplications
      class ContestApplicationController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        contest_application = ContestApplication.new(
          user_id: contest_application_create_params[:user_id],
          contest_id: contest_application_create_params[:contest_id]
        )
        if contest_application.save
          render json: contest_application, status: 201
        else
          render json: { error: "An Error occurred #{contest_application.errors.full_messages}" }, status: 400
        end
      rescue StandardError => e
        render json: { error: "An Error occurred #{e.message}" }, status: 400
      end

      def index
        contest_applications = get_contest_application_for_current_user
        render json: contest_applications, status: 200
      end

      def delete
        contest_application = get_contest_application_by_id
        if contest_application
          contest_application.delete
          render json: nil, status: 204
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      end

      def show
        contest_application = get_contest_application_by_id
        if contest_application
          render json: contest_application, status: 200
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      end

      private

      def contest_application_create_params
        params.require(:contest_application).permit(%i[
                                                      user_id
                                                      contest_id
                                                    ])
      end

      def get_contest_application_by_id
        @contest_application = ContestApplication.find_by(id: params[:id], user: current_api_v1_user)
      end

      def get_contest_application_for_current_user
        @contest_applications = ContestApplication.where(user: current_api_v1_user)
      end
      end
    end
  end
end
