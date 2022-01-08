# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::AssignStockPrice do
  Delayed::Worker.delay_jobs = false

  let(:symbol) { 'AAPL' }
  let(:reg_time) { 1_631_022_278 }
  let(:summarizing_time) { 1_631_022_578 }

  context 'not existing stock_id' do
    let(:stock_id) { 25_565 }
    let(:contest_application_id) { 228 }

    it 'must crash' do
      expect do
        ContestsServices::AssignStockPrice.call contest_application_id,
                                                stock_id,
                                                reg_time,
                                                'reg'
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'existing stock_id' do
    let!(:stock) do
      create :stock, name: symbol
    end
    let!(:contest) do
      create :contest
    end
    let!(:user) do
      create :user
    end
    let!(:contest_application) do
      create :contest_application, user_id: user.id, contest_id: contest.id
    end

    context 'registration price' do
      let!(:contest_application_stock) do
        create :contest_application_stock,
               contest_application_id: contest_application.id,
               stock_id: stock.id,
               reg_price: nil
      end

      it 'correctly changed' do
        last = Stock.last.name
        expect(last).to eq(symbol)

        last = ContestApplicationStock.last.reg_price
        expect(last).to eq(nil)

        actual_reg_price = FinnhubServices::GetQuotePriceOnTime.call(symbol, reg_time).result

        ContestsServices::AssignStockPrice.call contest_application_stock.contest_application_id,
                                                contest_application_stock.stock_id,
                                                reg_time,
                                                'reg'

        ca = ContestApplicationStock.find(contest_application_stock.id)

        expect(ca.reg_price).to eq(actual_reg_price)
      end
    end

    context 'summarizing price' do
      let!(:contest_application_stock) do
        create :contest_application_stock,
               contest_application_id: contest_application.id,
               stock_id: stock.id,
               reg_price: 150,
               final_price: nil
      end

      it 'correctly changed' do
        last = Stock.last.name
        expect(last).to eq(symbol)

        expect(ContestApplication.exists?(contest_application_stock.contest_application_id)).to eq(true)

        last = ContestApplicationStock.last.final_price
        expect(last).to eq(nil)

        actual_final_price = FinnhubServices::GetQuotePriceOnTime.call(symbol, summarizing_time).result

        ContestsServices::AssignStockPrice.call contest_application_stock.contest_application_id,
                                                contest_application_stock.stock_id,
                                                summarizing_time,
                                                'summarize'

        ca = ContestApplicationStock.find(contest_application_stock.id)

        expect(ca.final_price).to eq(actual_final_price)
      end
    end
  end
end
