# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::CreateContest do
  Delayed::Worker.delay_jobs = false

  context 'correct division name' do
    context 'presented as symbol' do
      let(:division_name) { Rails.configuration.divisions.keys[0].to_sym }
      let(:division_params) { Rails.configuration.divisions[division_name] }

      it 'creates contest' do
        contest = ContestsServices::CreateContest.call(division_name).result
        expect(contest).to eq(Contest.last)
      end

      it 'must create contest with parameters from config' do
        ContestsServices::CreateContest.call(division_name)
        contest = Contest.last

        expect(contest.max_fantasy_points_threshold).to eq(division_params[:fantasy_points_threshold])

        reg_duration_bounds = division_params[:reg_duration_range].split('..')
        reg_duration_lb = reg_duration_bounds[0].to_f * 60.0 - 0.5
        reg_duration_ub = reg_duration_bounds[1].to_f * 60.0 + 0.5
        actual_duration = (contest.reg_ending_at - contest.created_at)
        expect(actual_duration).to be_between(reg_duration_lb, reg_duration_ub)

        summarizing_duration_bounds = division_params[:summarizing_duration_range].split('..')
        summarizing_duration_lb = summarizing_duration_bounds[0].to_f * 60.0 - 0.5
        summarizing_duration_ub = summarizing_duration_bounds[1].to_f * 60.0 + 0.5
        actual_duration = (contest.summarizing_at - contest.reg_ending_at)
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
        contest = ContestsServices::CreateContest.call(division_name).result
        expect(contest).to eq(Contest.last)
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
      let(:range_string) { "#{lower_bound}..#{upper_bound}" }

      it 'must correctly cast string to range' do
        range = range_string.to_s.split('..').inject { |l, r| l.to_i..r.to_i }
        lb = range.begin
        ub = range.end
        expect(lower_bound).to eq(lb)
        expect(upper_bound).to eq(ub)
      end
    end
  end
end
