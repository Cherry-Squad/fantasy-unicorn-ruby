# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::SummarizeContest do
  Delayed::Worker.delay_jobs = false

  let!(:contest) do
    create :contest, status: Contest.statuses[:reg_ended],
                     max_fantasy_points_threshold: 600,
                     reg_ending_at: 1.day.ago,
                     summarizing_at: 3.hours.ago
  end
  let!(:user) { create :user }
  let!(:contest_application) { create :contest_application, user_id: user.id, contest_id: contest.id }
  let!(:stock1) { create :stock, name: 'IBM' }
  let!(:stock2) { create :stock, name: 'MSFT' }
  let!(:contest_application_stock1) do
    create :contest_application_stock,
           contest_application_id: contest_application.id,
           stock_id: stock1.id,
           reg_price: 155.0,
           direction_up: true
  end
  let!(:contest_application_stock2) do
    create :contest_application_stock,
           contest_application_id: contest_application.id,
           stock_id: stock2.id,
           reg_price: 148.0,
           direction_up: false
  end

  it 'contest finished' do
    ContestsServices::SummarizeContest.call contest.id

    expect(Contest.find(contest.id).status).to eq('finished')
  end
end
