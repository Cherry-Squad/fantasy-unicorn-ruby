# frozen_string_literal: true

module Api
  module V1
    class StockController < DeviseTokenAuth::RegistrationsController
      before_action :authenticate_api_v1_user!

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
        stocks = get_stocks_for_current_user
        render json: stocks, status: 200
      end

      def update
        stock = get_stock_by_id
        if stock
          if stock.update(stock_update_params)
            render json: stock, status: 201
          else
            render json: { error: "An Error occurred #{stock.errors.full_messages}" }, status: 400
          end
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      rescue StandardError => e
        render json: { error: "An Error occurred #{e.message}" }, status: 400
      end

      def delete
        stock = get_stock_by_id
        if stock
          stock.delete
          render json: nil, status: 204
        else
          render json: { status: 'Not Found 404' }, status: 404
        end
      end

      def show
        stock = get_stock_by_id
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

      def stock_update_params
        params.require(:stock).permit(%i[
                                        id
                                        name
                                      ])
      end

      def get_stock_by_id
        @stock = Stock.find_by(id: params[:id], user: current_api_v1_user)
      end

      def get_stocks_for_current_user
        @stocks = Stock.where(user: current_api_v1_user)
      end
    end
  end
end
