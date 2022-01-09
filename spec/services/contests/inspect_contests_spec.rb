# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::InspectContests do
  Delayed::Worker.delay_jobs = false

  context 'Contests table was empty' do
    let(:init_active_contests) { Contest.where.not(status: 'finished').size }

    it 'and contests was created' do
      expect(init_active_contests).to eq(0)

      maximum_contests = 0
      Rails.configuration.divisions.each_key do |division|
        maximum_contests += Rails.configuration.divisions[division][:contests_amount]
      end

      ContestsServices::InspectContests.call
      active_contests = Contest.where.not(status: 'finished').size
      expect(active_contests).to eq(maximum_contests)
    end
  end

  context 'There were active contests' do
    let(:init_active_contests) { Contest.where.not(status: 'finished').size }
    before do
      ContestsServices::CreateContest.call(:div1)
      ContestsServices::CreateContest.call(:div2)
      ContestsServices::CreateContest.call(:div3)
    end

    it 'and contests was created' do
      expect(init_active_contests).to eq(3)

      maximum_contests = 0
      Rails.configuration.divisions.each_key do |division|
        maximum_contests += Rails.configuration.divisions[division][:contests_amount]
      end

      ContestsServices::InspectContests.call

      active_contests = Contest.where.not(status: 'finished').size
      expect(active_contests).to eq(maximum_contests)
    end
  end
end
