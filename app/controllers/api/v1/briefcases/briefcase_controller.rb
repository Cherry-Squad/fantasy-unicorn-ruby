# frozen_string_literal: true

module Api
  module V1
    module Briefcases
      # BriefcaseController class
      class BriefcaseController < ApplicationController
        before_action :authenticate_api_v1_user!

        def create
          briefcase = Briefcase.new(
            expiring_at: Time.now.utc + 604_800,
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
          briefcases = briefcases_for_current_user
          render json: briefcases, status: 200
        end

        def update
          briefcase = briefcase_by_id
          stock = safe_stock
          if briefcase && stock
            if params[:add] == true
              unless briefcase.stock_ids.include? stock.id
                stocks = briefcase.stocks
                stocks << stock
              end
            else
              if briefcase.stock_ids.include? stock.id
                stocks = briefcase.stocks
                stocks.delete(stock)
              end
            end
            render json: briefcase, status: 201
          elsif safe_stock.nil?
            render json: { status: 'Bad Request ( Stock not Found )' }, status: 400
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        rescue StandardError => e
          render json: { error: "An Error occurred #{e.message}" }, status: 400
        end

        def delete
          briefcase = briefcase_by_id
          if briefcase
            briefcase.delete
            render json: nil, status: 204
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        def show
          briefcase = briefcase_by_id
          if briefcase
            render json: briefcase, status: 200
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        private

        def safe_stock
          @stock = Stock.find_by(id: params[:stock_id])
        end

        def briefcase_by_id
          @briefcase = Briefcase.find_by(id: params[:id], user: current_api_v1_user)
        end

        def briefcases_for_current_user
          @briefcases = Briefcase.where(user: current_api_v1_user)
        end
      end
    end
  end
end
