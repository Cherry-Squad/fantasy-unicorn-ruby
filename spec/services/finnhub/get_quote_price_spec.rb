# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinnhubServices::GetQuotePrice do
  let(:symbol) { 'AAPL' }
  context 'with a stubbed api and predefined response' do
    let(:quote_response) do
      OpenStruct.new(
        c: 261.74,
        h: 263.31,
        l: 260.68,
        o: 261.07,
        pc: 259.45,
        t: 1_582_641_000
      )
    end

    let(:finnhub_client) { double('finnhub_client', quote: quote_response) }

    it 'is returning correct price' do
      quote_price_response = FinnhubServices::GetQuotePrice.call(symbol, finnhub_client)
      expect(quote_price_response.result).to eq(quote_response[:c])
    end
  end

  context 'with the real api' do
    it 'must have an api key' do
      expect(Settings.finance_api.finnhub.api_key).to_not be_nil
    end

    it 'is return correct price' do
      quote_price_response = FinnhubServices::GetQuotePrice.call(symbol)
      expect(quote_price_response.result).to be_a(Float).and be > 0
    end
  end
end
