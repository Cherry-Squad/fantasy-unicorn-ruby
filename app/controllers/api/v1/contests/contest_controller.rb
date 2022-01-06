# frozen_string_literal: true

module Api
  module V1
    module Contests
      # ContestController class
      class ContestController < ApplicationController
        before_action :authenticate_api_v1_user!

        def create
          contest = Contest.new(
            coins_entry_fee: create_params[:coins_entry_fee],
            direction_strategy: create_params[:direction_strategy],
            fixed_direction_up: create_params[:fixed_direction_up],
            max_fantasy_points_threshold: create_params[:max_fantasy_points_threshold],
            reg_ending_at: create_params[:reg_ending_at],
            status: create_params[:status],
            summarizing_at: create_params[:summarizing_at],
            use_briefcase_only: create_params[:use_briefcase_only],
            use_disabled_multipliers: create_params[:use_disabled_multipliers],
            use_inverted_stock_prices: create_params[:use_inverted_stock_prices]
          )
          if contest.save
            render json: contest, status: 201
          else
            render json: { error: "an error occurred #{contest.errors.full_messages}" }, status: 400
          end
        rescue StandardError => e
          render json: { error: "an error occurred #{e.message}" }, status: 400
        end

        def index
          contests = all_contests
          render json: contests, status: 200
        end

        def delete
          contest = contest_by_id
          if contest
            contest.delete
            render json: nil, status: 204
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        def show
          contest = contest_by_id
          if contest
            render json: contest, status: 200
          else
            render json: { status: 'Not Found 404' }, status: 404
          end
        end

        private

        def create_params
          params.require(:contest).permit(%i[
                                            coins_entry_fee
                                            direction_strategy
                                            fixed_direction_up
                                            max_fantasy_points_threshold
                                            reg_ending_at
                                            status
                                            summarizing_at
                                            use_briefcase_only
                                            use_disabled_multipliers
                                            use_inverted_stock_prices
                                          ])
        end

        def contest_by_id
          @contest = Contest.find_by(id: params[:id])
        end

        def all_contests
          Contest.all
        end
      end
    end
  end
end
