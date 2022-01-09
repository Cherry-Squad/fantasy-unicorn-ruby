# frozen_string_literal: true

module Api
  module V1
    module ContestApplications
      # ContestApplicationController class
      class ContestApplicationController < ApplicationController
        before_action :authenticate_api_v1_user!

        def create
          contest_application = ContestApplication.new(
            user_id: create_params[:user_id],
            contest_id: create_params[:contest_id]
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
          contest_applications = if params[:contest_id]
                                   contest_application_by_contest
                                 else
                                   contest_application_for_current_user
                                 end
          render json: contest_applications.as_json(include: :user), status: 200
        end

        def delete
          contest_application = contest_application_by_id
          if contest_application
            contest_application.delete
            render json: nil, status: 204
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        def show
          contest_application = contest_application_by_id
          if contest_application
            render json: contest_application, status: 200
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        private

        def create_params
          params.require(:contest_application).permit(%i[
                                                        user_id
                                                        contest_id
                                                      ])
        end

        def contest_application_by_id
          @contest_application = ContestApplication.find_by(id: params[:id], user: current_api_v1_user)
        end

        def contest_application_for_current_user
          @contest_applications = ContestApplication.where(user: current_api_v1_user)
        end

        def contest_application_by_contest
          @contest_applications = ContestApplication.where(contest_id: params[:contest_id])
        end
      end
    end
  end
end
