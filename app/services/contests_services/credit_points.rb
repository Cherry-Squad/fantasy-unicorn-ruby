# frozen_string_literal: true

module ContestsServices
  # Closes the registration for the contest with the specified id
  # or deletes the competition record if it has no participants
  class CreditPoints < Patterns::Service
    def initialize(contest_id)
      super()
      @contest_id = contest_id
    end

    def call
      find_contest_application_ids
      end_contest
    end

    private

    def find_contest_application_ids
      @contest_application_ids = []

      ContestApplication.where(contest_id: @contest_id).find_each do |contest_application|
        @contest_application_ids.append(contest_application.id)
      end
    end

    def calculate_deltas; end

    def end_contest
      contest = Contest.find(@contest_id)
      contest.status = Contest.statuses[:finished]
      contest.save!
    end
  end
end
