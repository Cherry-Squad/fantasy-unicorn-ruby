# frozen_string_literal: true

module ContestsServices
  # Calculates the positions of the players in the contest
  # results table. Gives all participants of the competition
  # coins and fantasy points, depending on their position in the table of results
  class CreditPoints < Patterns::Service
    def initialize(contest_id)
      super()
      @contest_id = contest_id
      @divisions = Rails.configuration.divisions
      @division_names = @divisions.keys
    end

    def call
      process_all_users
      end_contest
    end

    private

    def process_all_users
      @contest_points = {}
      calculate_base_deltas_for Contest.find(@contest_id)

      find_contest_application_ids
      @contest_application_ids.each do |contest_app_id|
        @contest_points[contest_app_id] = process_user contest_app_id
      end
      @contest_points = @contest_points.sort_by(&:last).reverse

      calculate_deltas
    end

    def find_contest_application_ids
      @contest_application_ids = []

      ContestApplication.where(contest_id: @contest_id).find_each do |contest_application|
        @contest_application_ids.append(contest_application.id)
      end
    end

    def calculate_deltas
      (0..(@contest_points.size - 1)).each do |k|
        contest_application = ContestApplication.find(@contest_points[k][0])

        contest_application.final_position = k + 1
        contest_application.coins_delta = calculate_coins_delta_for k + 1
        contest_application.fantasy_points_delta = calculate_fp_delta_for k + 1
        contest_application.save!

        credit_deltas_for contest_application
      end
    end

    def calculate_coins_delta_for(place)
      n = @contest_points.size.to_f
      point = Float(place) * n / (n + 1)
      @base_division_coins_delta * (1 - point / n)
    end

    def calculate_fp_delta_for(place)
      n = @contest_points.size.to_f
      point = Float(place) * n / (n + 1)
      2 * @base_division_fp_delta * (0.5 - point / n)
    end

    def credit_deltas_for(contest_application)
      user = User.find(contest_application.user_id)
      user.coins = [user.coins + contest_application.coins_delta, 1].max
      user.fantasy_points = [user.fantasy_points + contest_application.fantasy_points_delta, 1].max
      user.save!
    end

    def calculate_base_deltas_for(contest)
      contest_division = division_by contest.max_fantasy_points_threshold

      @base_division_points_for_stock = @divisions[@division_names[contest_division]][:base_points]
      @base_division_coins_delta = @divisions[@division_names[contest_division]][:base_coins_delta]
      @base_division_fp_delta = @divisions[@division_names[contest_division]][:base_fp_delta]
    end

    def process_user(contest_app_id)
      points = 0
      ContestApplicationStock.where(contest_application_id: contest_app_id).find_each do |cas|
        points += points_for_stock cas
      end
      user = User.find(ContestApplication.find(contest_app_id).user_id)
      points * division_multiplier_of(user)
    end

    def points_for_stock(cas)
      points_for_stock = @base_division_points_for_stock * cas.multiplier
      points_for_stock *= -1 unless cas.direction_up
      points_for_stock *= -1 unless cas.reg_price <= cas.final_price
      points_for_stock
    end

    def division_multiplier_of(user)
      user_fantasy_points = user.fantasy_points
      contest_fantasy_points = Contest.find(@contest_id).max_fantasy_points_threshold

      user_division = division_by user_fantasy_points
      contest_division = division_by contest_fantasy_points
      return 1.0 if user_division <= contest_division

      [1.0 - 0.2 * (user_division - contest_division), 0.1].max
    end

    def division_by(fantasy_points)
      (0...(@division_names.size - 1)).each do |k|
        return k if fantasy_points <= @divisions[@division_names[k]][:fantasy_points_threshold]
      end

      @division_names.size - 1
    end

    def end_contest
      contest = Contest.find(@contest_id)
      contest.status = Contest.statuses[:finished]
      contest.save!
    end
  end
end
