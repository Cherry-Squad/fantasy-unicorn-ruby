# frozen_string_literal: true

module Api
  module V1
    module Stocks
      # StockController class
      class StockController < ApplicationController
        # before_action :authenticate_api_v1_user!

        def create
          stock = Stock.new(
            name: stock_create_params[:name]
          )
          if stock.save
            render json: stock, status: 201
          else
            render json: { error: "An Error occurred #{stock.errors.full_messages}" }, status: 400
          end
        rescue StandardError => e
          render json: { error: "An Error occurred #{e.message}" }, status: 400
        end

        def index
          stocks = stocks_for_current_user
          render json: stocks, status: 200
        end

        def delete
          stock = stock_by_id
          if stock
            stock.delete
            render json: nil, status: 204
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        def show
          stock = safe_stock
          if stock
            render json: stock, status: 200
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        private

        def stock_create_params
          params.require(:stock).permit([
                                          :name
                                        ])
        end

        def stock_by_id
          briefcase = Briefcase.find_by(user: current_api_v1_user)
          @stock = briefcase.stocks.find(params[:id]) if briefcase.stocks.exists?(id: params[:id])
        end

        def safe_stock
          @stock = Stock.find_by(id: params[:id])
        end

        def stocks_for_current_user
          briefcase = Briefcase.find_by(user: current_api_v1_user)
          @stocks = briefcase.stocks
        end
      end
    end
  end
end
