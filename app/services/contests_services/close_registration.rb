# frozen_string_literal: true

module ContestsServices
  # Closes the registration for the contest with the specified id
  # or deletes the competition record if it has no participants
  class CloseRegistration < Patterns::Service
    def initialize(contest_id)
      super()
      @contest_id = contest_id
    end

    def call
      change_status_to_reg_ended

      registered_users_amount = ContestApplication.where(contest_id: @contest_id).size
      if registered_users_amount.zero?
        @contest.destroy
      elsif !Rails.env.test?
        ContestsServices::SummarizeContest.delay(run_at: @contest.summarizing_at,
                                                 queue: 'contest_processing').call @contest_id
      end
    end

    private

    def change_status_to_reg_ended
      @contest = Contest.find(@contest_id)
      @contest.status = Contest.statuses[:reg_ended]
      @contest.save
    end
  end
end
