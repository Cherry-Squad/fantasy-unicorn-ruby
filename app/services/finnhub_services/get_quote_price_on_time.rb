# frozen_string_literal: true

module FinnhubServices
  # GetQuotePriceOnTime provides the quote price from finnhub.io for a given symbol (ticker) at a specific time.
  class GetQuotePriceOnTime < Patterns::Service
    def initialize(stock_name, timestamp, finnhub_client = FinnhubRuby::DefaultApi.new)
      super()
      time_shift = Rails.configuration.time_shift
      @symbol = stock_name
      @time = timestamp + time_shift
      @finnhub_client = finnhub_client
    end

    def call
      candle = request_candle
      raise ApiError::UnknownSymbol, @symbol if candle.s == 'no_data'

      request_price candle
    rescue FinnhubRuby::ApiError => e
      raise ApiError::TooManyRequests if e.code == 429

      raise ApiError, e.message
    end

    private

    def request_candle
      @finnhub_client.stock_candles @symbol, '1', @time - 1.days.to_i, @time + 1.hour.to_i
    end

    def request_price(candle)
      candle.o.last
    end
  end
end
