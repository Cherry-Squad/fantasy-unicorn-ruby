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
            ActiveRecord::Base.transaction do
              contest_application = create_contest_application contest
              contest_app_stocks = array_of_contest_app_stocks contest_application
              write_off_money_from_user contest
              assign_stocks_prices contest_app_stocks, contest_application.id
              render json: { contest_app_stocks: contest_app_stocks }, status: 201
            end
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        rescue ActiveRecord::RecordInvalid => e
          render json: { error: e.message.to_s }, status: 404
        rescue StandardError => e
          render json: { error: "an error occurred: #{e.message}" }, status: 400
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

        def write_off_money_from_user(contest)
          user = current_api_v1_user
          raise StandardError, 'User has no coins' unless user.coins.to_i > contest.coins_entry_fee.to_i

          user.coins = user.coins.to_i - contest.coins_entry_fee.to_i
          user.save
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
            contest_application_stock.save!
            array.append contest_application_stock
          end
          array
        end

        def assign_stocks_prices(contest_app_stocks, contest_app_id)
          time = Time.now.utc.to_i
          contest_app_stocks.each do |contest_app_stock|
            ContestsServices::AssignStockPrice.delay(queue: 'contest_processing')
                                              .call contest_app_id.to_i, contest_app_stock.stock_id.to_i, time, 'reg'
          end
        end

        def create_params
          params.require(:contest_register).permit({ items: %i[stock_id multiplier direction_up] })
        end

        def contest_by_id
          Contest.find_by(id: params[:id])
        end
      end
    end
  end
end
