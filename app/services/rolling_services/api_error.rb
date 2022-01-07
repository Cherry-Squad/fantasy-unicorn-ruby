# frozen_string_literal: true

module RollingServices
    # ApiError is a generic error that occurs due to an error after update user's coins
    class ApiError < StandardError
      def initialize(msg = nil)
        super
      end
    end
  end
  