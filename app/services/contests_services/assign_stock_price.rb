# frozen_string_literal: true

module ContestsServices
  # Template service description
  # @assignation can be in ['reg', 'summarize']
  class AssignStockPrice < Patterns::Service
    def initialize(contest_app_id, stock_id, timestamp, assignation)
      super()
      @contest_application_id = contest_app_id
      @stock_id = stock_id
      @timestamp = timestamp
      @assignation = assignation
    end

    def call
      assign_price

      # Place to validate the end of all operations on this ContestApplication, if we need it
    rescue FinnhubRuby::ApiError => e
      raise ApiError, e.message unless e.code == 429

      reschedule_job
    end

    private

    def stock_name(stock_id)
      Stock.find(stock_id).name
    end

    def assign_price
      price = FinnhubServices::GetQuotePriceOnTime.call(stock_name(@stock_id), @timestamp).result
      contest_application_stocks = ContestApplicationStock.where(contest_application_id: @contest_application_id,
                                                                 stock_id: @stock_id).first

      contest_application_stocks.reg_price = price if @assignation == 'reg'
      contest_application_stocks.final_price = price if @assignation == 'summarize'

      contest_application_stocks.save
    end

    def reschedule_job
      ContestsServices::AssignStockPrice.delay(queue: 'contest_processing',
                                               run_at: 1.minutes.from_now)
                                        .call @contest_application_id, @stock_id, @timestamp, @assignation
    end
  end
end
