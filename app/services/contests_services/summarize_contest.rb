# frozen_string_literal: true

module ContestsServices
  # Template service description
  class SummarizeContest < Patterns::Service
    def initialize(contest_id)
      super()
      @contest_id = contest_id
    end

    def call
      puts "Вызвано подведение итогов для контеста #{@contest_id}"
    end
  end
end
