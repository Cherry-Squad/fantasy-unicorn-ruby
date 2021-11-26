# frozen_string_literal: true

module FinnhubServices
  # This service provides the current quote price from finnhub.io
  # for a given symbol (ticker).
  class GetQuotePrice < Patterns::Service
    def initialize(stock_id, finnhub_client = FinnhubRuby::DefaultApi.new)
      super()
      @symbol = stock_id
      @finnhub_client = finnhub_client
    end

    def call
      result = @finnhub_client.quote(@symbol)
      result.c
    rescue FinnhubRuby::ApiError => e
      raise FinnhubServices::TooManyRequests if e.code == 429

      raise FinnhubServices::ApiError
    end
  end
end
