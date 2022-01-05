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
      reg_ending_at = Time.now + @reg_duration
      summarizing_at = reg_ending_at + @summarizing_duration

      Contest.create(
        coins_entry_fee: @coins_entry_fee,
        max_fantasy_points_threshold: @max_fantasy_points_threshold,
        reg_ending_at: reg_ending_at,
        summarizing_at: summarizing_at
      )
    end
    handle_asynchronously :call, queue: 'contest_creating'

    private

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
