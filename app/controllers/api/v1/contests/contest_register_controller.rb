# frozen_string_literal: true

module Api
  module V1
    module Contests
      # ContestRegisterController class
      class ContestRegisterController < ApplicationController
        before_action :authenticate_api_v1_user!

        def create
          contest = contest_by_id
          if contest
            contest_application = create_contest_application contest
            contest_app_stocks = array_of_contest_app_stocks contest_application
            assign_stocks_prices contest_app_stocks, contest_application.id
            render json: { contest_app_stocks: contest_app_stocks }, status: 201
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        rescue StandardError => e
          render json: { error: "an error occurred #{e.message}" }, status: 400
        end

        private

        def create_contest_application(contest)
          contest_application = ContestApplication.new(
            user_id: current_api_v1_user.id,
            contest_id: contest.id
          )
          contest_application.save
          contest_application
        end

        def array_of_contest_app_stocks(contest_application)
          array = []
          create_params[:items].each do |param|
            contest_application_stock = ContestApplicationStock.create(
              multiplier: param[:multiplier],
              contest_application_id: contest_application.id,
              stock_id: param[:stock_id],
              direction_up: param[:direction_up]
            )
            contest_application_stock.save
            array.append contest_application_stock
          end
          array.delete_if { |el| el[:id].nil? }
        end

        def assign_stocks_prices(contest_app_stocks, contest_app_id)
          time = Time.now.utc.to_i
          contest_app_stocks.each do |contest_app_stock|
            ContestsServices::AssignStockPrice.delay(queue: 'contest_processing')
                                              .call contest_app_id.to_i, contest_app_stock.stock_id.to_i, time, 'reg'
          end
        end

        def create_params
          params.require(:contest_register).permit({ items: %i[stock_id multiplier] })
        end

        def contest_by_id
          Contest.find_by(id: params[:id])
        end
      end
    end
  end
end
