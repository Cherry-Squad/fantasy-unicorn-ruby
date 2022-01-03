# frozen_string_literal: true

module Api
  module V1
    class BriefcaseController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        briefcase = Briefcase.new(
          expiring_at: briefcase_create_params[:expiring_at],
          user_id: current_api_v1_user[:id]
        )
        if briefcase.save
          render json: briefcase, status: 201
        else
          render json: { error: 'Bad request ( invalid data )' }, status: 400
        end
      rescue StandardError
        render json: { error: 'Bad request ( invalid data )' }, status: 400
      end

      def index
        briefcases = get_briefcases
        render json: briefcases, status: 200
      end

      def update
        briefcase = get_briefcase_by_id
        if briefcase
          if briefcase.update(briefcase_update_params)
            render json: briefcase, status: 201
          else
            render json: { error: 'Bad request ( invalid data )' }, status: 400
          end
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      rescue StandardError
        render json: { error: 'Bad request ( invalid data )' }, status: 400
      end

      def delete
        briefcase = get_briefcase_by_id
        if briefcase
          briefcase.delete
          render json: nil, status: 204
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      end

      def show
        briefcase = get_briefcase_by_id
        if briefcase
          render json: briefcase, status: 200
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      end

      private

      def briefcase_create_params
        params.require(:briefcase).permit([
                                            :expiring_at
                                          ])
      end

      def briefcase_update_params
        params.require(:briefcase).permit(%i[
                                            id
                                            expiring_at
                                          ])
      end

      def get_briefcase_by_id
        @briefcase = Briefcase.find_by(id: params[:id], user: current_api_v1_user)
      end

      def get_briefcases
        @briefcases = Briefcase.where(user: current_api_v1_user)
      end
    end
  end
end
