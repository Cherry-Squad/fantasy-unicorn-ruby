# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::InspectContests do
  Delayed::Worker.delay_jobs = false
  let(:maximum_contests) { Rails.configuration.contests_generating[:maximum_contests].to_i }

  context 'Contests table was empty' do
    let(:init_active_contests) { Contest.where.not(status: 'finished').size }

    it 'and contests was created' do
      expect { :init_active_contests }.eql? 0
      ContestsServices::InspectContests.call
      active_contests = Contest.where.not(status: 'finished').size
      expect { active_contests }.eql? :maximum_contests
    end
  end

  context 'There were active contests' do
    ContestsServices::CreateContest.call(:div1)
    ContestsServices::CreateContest.call(:div2)
    ContestsServices::CreateContest.call(:div3)
    let(:init_active_contests) { Contest.where.not(status: 'finished').size }

    it 'and contests was created' do
      expect { :init_active_contests }.eql? 3
      ContestsServices::InspectContests.call

      active_contests = Contest.where.not(status: 'finished').size
      expect { active_contests }.eql? :maximum_contests
    end
  end
end
