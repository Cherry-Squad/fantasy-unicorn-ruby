# frozen_string_literal: true

module ContestsServices
  # For contest with @contest_id, it calculates the value
  # of stocks in the portfolios of its participants and,
  # depending on this, awards points to them.
  class SummarizeContest < Patterns::Service
    def initialize(contest_id)
      super()
      @contest_id = contest_id
      @summarizing_time = Contest.find(contest_id).summarizing_at.to_i
    end

    def call
      find_contest_applications
      assign_final_prices
    end

    private

    def find_contest_applications
      @contest_application_ids = []
      ContestApplication.where(contest_id: @contest_id).find_each do |contest_application|
        @contest_application_ids.append(contest_application.id)
      end
    end

    def assign_final_prices
      ContestApplicationStock.where(contest_application_id: @contest_application_ids).find_each do |contest_app_stock|
        contest_application_id = contest_app_stock.contest_application_id
        stock_id = contest_app_stock.stock_id

        ContestsServices::AssignStockPrice.delay(queue: 'contest_processing')
                                          .call(contest_application_id, stock_id, @summarizing_time, 'summarize')
      end
    end
  end
end
