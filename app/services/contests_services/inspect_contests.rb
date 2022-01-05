# frozen_string_literal: true

module ContestsServices
  # Checks if new contests need to be created and creates them if needed
  class InspectContests < Patterns::Service
    def initialize
      super
      @maximum_contests = Rails.configuration.contests_generating[:maximum_contests].to_i
      @cooldown_bounds_string = Rails.configuration.contests_generating[:cooldown_bounds]
    end

    def call
      create_contests if need_to_create?

      calculate_cooldown
      ContestsServices::InspectContests.delay(run_at: @creating_cooldown.minutes.from_now).call unless Rails.env.test?
    end
    handle_asynchronously :call, queue: 'contest_creating'

    private

    def create_contests
      while @active_contests_amount < @maximum_contests
        @active_contests_amount += 1
        CreateContest.call(:div1)
      end
    end

    def need_to_create?
      @active_contests_amount = Contest.where.not(status: 'finished').size
      return false unless @active_contests_amount

      @maximum_contests > @active_contests_amount
    end

    def calculate_cooldown
      @rng = Random.new
      creating_cooldown_range = range_from @cooldown_bounds_string
      @creating_cooldown = @rng.rand(creating_cooldown_range)
    end

    def range_from(string)
      string.to_s.split('..').inject { |l, r| l.to_i..r.to_i }
    end
  end
end
