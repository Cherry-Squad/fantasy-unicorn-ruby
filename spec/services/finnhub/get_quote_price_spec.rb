# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinnhubServices::GetQuotePrice do
  let(:symbol) { 'AAPL' }

  context 'created with a stubbed api' do
    let(:finnhub_client) { double('finnhub_client') }

    context 'and predefined correct response' do
      before do
        allow(finnhub_client).to receive(:quote) do
          OpenStruct.new(
            c: 156.81,
            d: -5.13,
            dp: -3.1678,
            h: 160.448,
            l: 156.36,
            o: 159.565,
            pc: 161.94,
            t: 1_637_949_603
          )
        end
      end

      it '#call return correct price' do
        quote_price_response = FinnhubServices::GetQuotePrice.call(symbol, finnhub_client)
        expect(quote_price_response.result).to eq(finnhub_client.quote[:c])
      end
    end

    context "and predefined response as if ticker isn't exists" do
      before do
        allow(finnhub_client).to receive(:quote) do
          OpenStruct.new(
            c: 0,
            d: nil,
            dp: nil,
            h: 0,
            l: 0,
            o: 0,
            pc: 0,
            t: 0
          )
        end
      end

      it '#call raises ApiError::TooManyRequests' do
        expect { FinnhubServices::GetQuotePrice.call(symbol, finnhub_client) }
          .to raise_error(FinnhubServices::ApiError::UnknownSymbol)
      end
    end

    context 'and predefined error' do
      let(:error_code) { nil }

      before do
        allow(finnhub_client).to receive(:quote).and_raise(FinnhubRuby::ApiError.new(code: error_code))
      end

      context 'with code 429' do
        let(:error_code) { 429 }

        it '#call raises ApiError::TooManyRequests' do
          expect { FinnhubServices::GetQuotePrice.call(symbol, finnhub_client) }
            .to raise_error(FinnhubServices::ApiError::TooManyRequests)
        end
      end

      context 'with code 500' do
        let(:error_code) { 500 }

        it '#call raises ApiError' do
          expect { FinnhubServices::GetQuotePrice.call(symbol, finnhub_client) }
            .to raise_error(FinnhubServices::ApiError)
        end
      end

      context 'with pseudo timeout error' do
        it '#call raises ApiError' do
          expect { FinnhubServices::GetQuotePrice.call(symbol, finnhub_client) }
            .to raise_error(FinnhubServices::ApiError)
        end
      end
    end
  end

  context 'created with the real api' do
    it 'must have an api key' do
      expect(Settings.finance_api.finnhub.api_key).to_not be_nil
    end

    it '#call return correct price' do
      quote_price_response = FinnhubServices::GetQuotePrice.call(symbol)
      expect(quote_price_response.result).to be_a(Float).and be > 0
    end

    context 'and with non-existent symbol' do
      let(:symbol) { 'AAPLERPQJER' }

      it '#call raises ApiError::UnknownSymbol' do
        expect { FinnhubServices::GetQuotePrice.call(symbol) }
          .to raise_error(FinnhubServices::ApiError::UnknownSymbol)
      end
    end
  end
end
