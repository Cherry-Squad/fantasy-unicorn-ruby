# frozen_string_literal: true

module ContestsServices
  # ApiError is a generic error that occurs due to an error after creating contests.
  class ApiError < StandardError
    def initialize(msg = nil)
      super
    end

    # UnknownDivision is an error that occurs due to failed attempt on creating the contest with division not in config.
    class UnknownDivision < ApiError
      def initialize(division_name)
        super("Contest creation config file doesnt contain division '#{division_name}'")
      end
    end
  end
end
