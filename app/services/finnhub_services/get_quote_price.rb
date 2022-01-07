# frozen_string_literal: true

module FinnhubServices
  # GetQuotePrice provides the current quote price from finnhub.io for a given symbol (ticker).
  #
  # Usage:
  # quote_price_response = FinnhubServices::GetQuotePrice.call()
  # puts quote_price_response.result
  class GetQuotePrice < Patterns::Service
    def initialize(stock_name, finnhub_client = FinnhubRuby::DefaultApi.new)
      super()
      @symbol = stock_name
      @finnhub_client = finnhub_client
    end

    def call
      result = @finnhub_client.quote(@symbol)
      price = result.c
      change = result.d

      raise ApiError::UnknownSymbol, @symbol if price.zero? && change.nil?

      price
    rescue FinnhubRuby::ApiError => e
      raise ApiError::TooManyRequests if e.code == 429

      raise ApiError, e.message
    end
  end
end
