# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::CloseRegistration do
  Delayed::Worker.delay_jobs = false

  let!(:contest) { create :contest }

  context 'There were users who registered for the contest' do
    let!(:contest_application1) { create :contest_application, contest_id: contest.id }
    let!(:contest_application2) { create :contest_application, contest_id: contest.id }
    let!(:contest_application3) { create :contest_application, contest_id: contest.id }

    it 'and the contest has changed its status to \'reg_ended\'' do
      users_amount = User.all.size

      expect(ContestApplication.where(contest_id: contest.id).size).to eq(users_amount)

      status = Contest.find(contest.id).status
      expect(status).to eq('created')

      ContestsServices::CloseRegistration.call contest.id

      status = Contest.find(contest.id).status
      expect(status).to eq('reg_ended')
    end
  end

  context 'There were no users who registered to participate in the contest ' do
    it 'and the contest was destroyed ' do
      expect(Contest.exists?(contest.id)).to eq(true)
      expect(ContestApplication.where(contest_id: contest.id).size).to eq(0)

      ContestsServices::CloseRegistration.call contest.id

      expect(Contest.exists?(contest.id)).to eq(false)
    end
  end
end
