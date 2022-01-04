# frozen_string_literal: true

module Api
  module V1
    class ContestApplicationStockController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        contest_application_stock = ContestApplicationStock.new(
          multiplier: contest_application_stock_create_params[:multiplier],
          contest_application_id: contest_application_stock_create_params[:contest_application_id],
          stock_id: contest_application_stock_create_params[:stock_id]
        )
        if contest_application_stock.save
          render json: contest_application_stock, status: 201
        else
          render json: { error: "An Error occurred #{contest_application_stock.errors.full_messages}" }, status: 400
        end
      rescue StandardError => e
        render json: { error: "An Error occurred #{e.message}" }, status: 400
      end

      def index
        contest_application_stocks = get_contest_application_stock_for_current_user
        render json: contest_application_stocks, status: 200
      end

      def update
        contest_application_stock = get_contest_application_stock_by_id
        if contest_application_stock
          if contest_application_stock.update(contest_application_stock_update_params)
            render json: contest_application_stock, status: 201
          else
            render json: { error: "An Error occurred #{contest_application_stock.errors.full_messages}" }, status: 400
          end
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      rescue StandardError => e
        render json: { error: "An Error occurred #{e.message}" }, status: 400
      end

      def delete
        contest_application_stock = get_contest_application_stock_by_id
        if contest_application_stock
          contest_application_stock.delete
          render json: nil, status: 204
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      end

      def show
        contest_application_stock = get_contest_application_stock_by_id
        if contest_application_stock
          render json: contest_application_stock, status: 200
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      end

      private

      def contest_application_stock_create_params
        params.require(:contest_application_stock).permit(%i[
                                                            multiplier
                                                            reg_price
                                                            contest_application_id
                                                            stock_id
                                                          ])
      end

      def contest_application_stock_update_params
        params.require(:contest_application_stock).permit(%i[
                                                            id
                                                            multiplier
                                                            reg_price
                                                            contest_application_id
                                                            stock_id
                                                          ])
      end

      def get_contest_application_stock_by_id
        @contest_application_stock = ContestApplicationStock.find_by(id: params[:id], user: current_api_v1_user)
      end

      def get_contest_application_stock_for_current_user
        @contest_application_stocks = ContestApplicationStock.where(user: current_api_v1_user)
      end
    end
  end
end
