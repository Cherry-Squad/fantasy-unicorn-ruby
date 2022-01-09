# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinnhubServices::GetQuotePriceOnTime do
  let(:symbol) { 'AAPL' }
  let(:time) { 1_631_022_248 + 30 }

  context 'created with a stubbed api' do
    let(:finnhub_client) { double('finnhub_client') }

    context 'and predefined correct response' do
      before do
        allow(finnhub_client).to receive(:stock_candles) do
          OpenStruct.new(
            o: [155.45, 155.45],
            h: [155.48, 155.5],
            l: [155.37, 155.18],
            c: [155.459, 155.23],
            v: [354_959.0, 414_609.0],
            t: [1_631_022_240, 1_631_022_300],
            s: 'ok'
          )
        end
      end
      it '#call return correct price' do
        quote_price_response = FinnhubServices::GetQuotePriceOnTime.call(symbol, time, finnhub_client)
        expected_price = finnhub_client.stock_candles[:o].last
        expect(quote_price_response.result).to eq(expected_price)
      end
    end

    context "and predefined response as if ticker isn't exists" do
      before do
        allow(finnhub_client).to receive(:stock_candles) do
          OpenStruct.new(
            o: [],
            h: [],
            l: [],
            c: [],
            v: [],
            t: [],
            s: 'no_data'
          )
        end
      end

      it '#call raises ApiError::UnknownSymbol' do
        expect { FinnhubServices::GetQuotePriceOnTime.call symbol, time, finnhub_client }
          .to raise_error(FinnhubServices::ApiError::UnknownSymbol)
      end
    end

    context 'and predefined error' do
      let(:error_code) { nil }

      before do
        allow(finnhub_client).to receive(:stock_candles).and_raise(FinnhubRuby::ApiError.new(code: error_code))
      end

      context 'with code 429' do
        let(:error_code) { 429 }

        it '#call raises ApiError::TooManyRequests' do
          expect { FinnhubServices::GetQuotePriceOnTime.call symbol, time, finnhub_client }
            .to raise_error(FinnhubServices::ApiError::TooManyRequests)
        end
      end

      context 'with code 500' do
        let(:error_code) { 500 }

        it '#call raises ApiError' do
          expect { FinnhubServices::GetQuotePriceOnTime.call symbol, time, finnhub_client }
            .to raise_error(FinnhubServices::ApiError)
        end
      end

      context 'with pseudo timeout error' do
        it '#call raises ApiError' do
          expect { FinnhubServices::GetQuotePriceOnTime.call symbol, time, finnhub_client }
            .to raise_error(FinnhubServices::ApiError)
        end
      end
    end
  end

  context 'created with the real api' do
    it 'must have an api key' do
      expect(Rails.application.credentials.finnhub_api_key).to_not be_nil
    end

    it '#call return correct price' do
      quote_price_response = FinnhubServices::GetQuotePriceOnTime.call(symbol, Time.now.to_i)
      expect(quote_price_response.result).to be_a(Float).and be > 0
    end

    context 'and with non-existent symbol' do
      let(:symbol) { 'BIBIZYANA' }

      it '#call raises ApiError::UnknownSymbol' do
        expect { FinnhubServices::GetQuotePriceOnTime.call symbol, time }
          .to raise_error(FinnhubServices::ApiError::UnknownSymbol)
      end
    end
  end
end
