
module Api
  module V1
    class ContestController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        begin
          contest = Contest.new(
                coins_entry_fee: contest_create_params[:coins_entry_fee],
                direction_strategy: contest_create_params[:direction_strategy],
                fixed_direction_up: contest_create_params[:fixed_direction_up],
                max_fantasy_points_threshold: contest_create_params[:max_fantasy_points_threshold],
                reg_ending_at: contest_create_params[:reg_ending_at],
                status: contest_create_params[:status],
                summarizing_at: contest_create_params[:summarizing_at],
                use_briefcase_only: contest_create_params[:use_briefcase_only],
                use_disabled_multipliers: contest_create_params[:use_disabled_multipliers],
                use_inverted_stock_prices: contest_create_params[:use_inverted_stock_prices]
          )
          if contest.save
            render json: contest, status: 201
          else
            render json: {error: "an error occurred #{contest.errors.full_messages}"}, status: 400
          end
        rescue => error
            render json: {error: "an error occurred #{error.message}"}, status: 400
        end
      end

      def index
          if params[:type] == "all"
            contests = get_contests
          else
            contests = get_contests_for_current_user
          end
          render json: contests, status: 200
      end

      def update
        begin
          contest = get_contest_by_id
          if contest
            if contest.update(contest_update_params)
                render json: contest, status: 201
            else
                render json: {error: "an error occurred #{contest.errors.full_messages}"}, status: 400
            end
          else
            render json: {status: "Not Found 404"}, status: 404
          end
        rescue => error
            render json: {error: "an error occurred #{error.message}"}, status: 400
        end
      end

      def delete
      contest = current_api_v1_user
        if contest
            contest.delete
            render json: nil, status: 204
        else
            render json: {status: "Not Found 404"}, status: 404
        end
      end

      def show
        contest = current_api_v1_user
        if contest
            render json: contest, status: 200
        else
            render json: {status: "Not Found 404"}, status: 404
        end
      end
      private
        def contest_create_params
            params.require(:contest).permit([
                :coins_entry_fee,
                :direction_strategy,
                :fixed_direction_up,
                :max_fantasy_points_threshold,
                :reg_ending_at,
                :status,
                :summarizing_at,
                :use_briefcase_only,
                :use_disabled_multipliers,
                :use_inverted_stock_prices
            ])
        end

        def contest_update_params
            params.require(:contest).permit([
                :id,
                :coins_entry_fee,
                :direction_strategy,
                :fixed_direction_up,
                :max_fantasy_points_threshold,
                :reg_ending_at,
                :status,
                :summarizing_at,
                :use_briefcase_only,
                :use_disabled_multipliers,
                :use_inverted_stock_prices
            ])
        end

        def get_contest_by_id
            @contest = Contest.find_by(id: params[:id], user: current_api_v1_user)
        end

        def get_contests_for_current_user
            @contests = Contest.where(user: current_api_v1_user)
        end

        def get_contests
            Contest.all
        end
    end
  end
end
