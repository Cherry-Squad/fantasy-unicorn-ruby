# frozen_string_literal: true

module FinnhubServices
  # piError is a generic error that occurs due to an error after a request to finnhub.
  class ApiError < StandardError
    def initialize(msg = nil)
      super
    end

    # TooManyRequests is an error that occurs due to too many requests to finnhub.
    # The user must stop executing requests within 1 minute if it receives this error.
    class TooManyRequests < ApiError
      def initialize
        super('Finnhub has returned 429 error')
      end
    end

    # UnknownSymbol is an error that occurs due to failed attempt on finding the symbol on finnhub.
    class UnknownSymbol < ApiError
      def initialize(symbol)
        super("Finnhub couldn't find symbol #{symbol}")
      end
    end
  end
end
