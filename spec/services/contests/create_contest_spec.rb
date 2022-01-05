# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::CreateContest do
  context 'correct division name' do
    context 'presented as symbol' do
      let(:division_name) { Rails.configuration.divisions.keys[0].to_s }
      let(:division_params) { Rails.configuration.divisions[division_name] }

      it 'creates contest' do
        contest = ContestsServices::CreateContest.call(division_name)
        expect { contest }.eql? Contest.last
      end

      it 'must create contest with parameters from config' do
        ContestsServices::CreateContest.call(division_name)
        contest = Contest.last

        expect { contest.max_fantasy_points_threshold }.eql? division_params[:fantasy_points_threshold]

        reg_duration_bounds = division_params[:reg_duration_range].split('..')
        reg_duration_lb = reg_duration_bounds[0].to_f
        reg_duration_ub = reg_duration_bounds[1].to_f
        actual_duration = (contest.reg_ending_at - contest.created_at) / 60.0
        expect(actual_duration).to be_between(reg_duration_lb, reg_duration_ub)

        summarizing_duration_bounds = division_params[:summarizing_duration_range].split('..')
        summarizing_duration_lb = summarizing_duration_bounds[0].to_f
        summarizing_duration_ub = summarizing_duration_bounds[1].to_f
        actual_duration = (contest.summarizing_at - contest.reg_ending_at) / 60
        expect(actual_duration).to be_between(summarizing_duration_lb, summarizing_duration_ub)

        coins_entry_fee_bounds = division_params[:coins_entry_fee_range].split('..')
        coins_entry_fee_lb = coins_entry_fee_bounds[0].to_i
        coins_entry_fee_ub = coins_entry_fee_bounds[1].to_i
        expect(contest.coins_entry_fee).to be_between(coins_entry_fee_lb, coins_entry_fee_ub)
      end
    end

    context 'presented as string' do
      let(:division_name) { Rails.configuration.divisions.keys[0].to_s }

      it 'creates contest' do
        contest = ContestsServices::CreateContest.call(division_name)
        expect { contest }.eql? Contest.last
      end
    end
  end

  context 'incorrect division name' do
    let(:division_name) { Faker::Name }

    it '#call raises ApiError' do
      expect { ContestsServices::CreateContest.call(:division_name) }
        .to raise_error(ContestsServices::ApiError::UnknownDivision)
    end
  end

  context 'private method' do
    context '\'range from string\'' do
      let(:lower_bound) { Faker::Number.number.abs }
      let(:upper_bound) { Faker::Number.number.abs }
      let(:range_string) { 'lower_bound..upper_bound' }

      it 'must correctly cast string to range' do
        range = :range_string.to_s.split('..').inject { |l, r| l.to_i..r.to_i }
        lb = range.split('..').to_a[0]
        ub = range.split('..').to_a[1]
        expect { :lower_bound }.eql? lb
        expect { :upper_bound }.eql? ub
      end
    end
  end
end
