# frozen_string_literal: true

module ContestsServices
  # Calculates the quote for Stock with @stock_id at @timestamp and assigns
  # it to field of ContestApplicationStocks, corresponding to
  # @contest_app_id and '@stock_id, depending on the specified @assignation.
  #
  # @assignation must be in ['reg', 'summarize']
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
      check_completeness if @assignation == 'summarize'
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

      contest_application_stocks.save!
    end

    def reschedule_job
      return if Rails.env.test?

      ContestsServices::AssignStockPrice.delay(queue: 'contest_processing',
                                               run_at: 1.minutes.from_now)
                                        .call @contest_application_id, @stock_id, @timestamp, @assignation
    end

    def check_completeness
      contest_id = ContestApplication.find(@contest_application_id).contest_id
      find_contest_application_ids contest_id

      finalize_contest contest_id if summarizing_completed?
    end

    def find_contest_application_ids(contest_id)
      @contest_application_ids = []

      ContestApplication.where(contest_id: contest_id).find_each do |contest_application|
        @contest_application_ids.append(contest_application.id)
      end
    end

    def summarizing_completed?
      !ContestApplicationStock.where(contest_application_id: @contest_application_ids, final_price: nil).exists?
    end

    def finalize_contest(contest_id)
      ContestsServices::CreditPoints.delay(queue: 'contest_processing').call(contest_id)
    end
  end
end
