# frozen_string_literal: true

module ContestsServices
  # Create contest with parameters of target division
  class CreateContest < Patterns::Service
    def initialize(division_name)
      super()
      @rng = Random.new
      @division_name = division_name
      raise ApiError::UnknownDivision, division_name unless
        Rails.configuration.divisions.keys.include? @division_name.to_sym

      set_division_params
    end

    def call
      calculate_times
      set_other_params

      contest = create_contest
      return contest if Rails.env.test?

      ContestsServices::CloseRegistration.delay(run_at: @reg_ending_at, queue: 'contest_processing').call contest.id

      contest
    end

    private

    def calculate_times
      @reg_ending_at = Time.now + @reg_duration
      @summarizing_at = @reg_ending_at + @summarizing_duration
    end

    def set_other_params
      @use_briefcase_only = [true, false].sample
      @direction_strategy = Contest.direction_strategies.to_a.sample[1]
      @fixed_direction_up = nil
      @fixed_direction_up = [true, false].sample if @direction_strategy == 'fixed'
      @use_disabled_multipliers = [true, false].sample
      @use_inverted_stock_prices = false
    end

    def create_contest
      Contest.create(
        coins_entry_fee: @coins_entry_fee,
        max_fantasy_points_threshold: @max_fantasy_points_threshold,
        reg_ending_at: @reg_ending_at, summarizing_at: @summarizing_at,
        use_briefcase_only: @use_briefcase_only,
        direction_strategy: @direction_strategy,
        fixed_direction_up: @fixed_direction_up,
        use_disabled_multipliers: @use_disabled_multipliers,
        use_inverted_stock_prices: @use_inverted_stock_prices
      )
    end

    def set_division_params
      division_params = Rails.configuration.divisions[@division_name]
      @max_fantasy_points_threshold = division_params[:fantasy_points_threshold]
      @coins_entry_fee = @rng.rand(range_from(division_params[:coins_entry_fee_range]))
      @reg_duration = @rng.rand(range_from(division_params[:reg_duration_range])).minutes
      @summarizing_duration = @rng.rand(range_from(division_params[:summarizing_duration_range])).minutes
    end

    def range_from(string)
      string.to_s.split('..').inject { |l, r| l.to_i..r.to_i }
    end
  end
end
