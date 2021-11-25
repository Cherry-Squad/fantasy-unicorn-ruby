# frozen_string_literal: true

# == Schema Information
#
# Table name: contests
#
#  id                           :bigint           not null, primary key
#  coins_entry_fee              :bigint           not null
#  direction_strategy           :string           not null
#  fixed_direction_up           :boolean
#  max_fantasy_points_threshold :bigint
#  reg_ending_at                :datetime         not null
#  status                       :string           not null
#  summarizing_at               :datetime         not null
#  use_briefcase_only           :boolean          not null
#  use_disabled_multipliers     :boolean          not null
#  use_inverted_stock_prices    :boolean          not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
require 'rails_helper'

RSpec.describe Contest, type: :model do
  it 'is valid with bare minimum attributes' do
    expect(create(:contest)).to be_valid
  end

  context 'with preconfigured stocks' do
    before do
      @contest = create :contest, :with_stocks
      @stocks = @contest.stocks
    end

    it 'is valid' do
      expect(@contest).to be_valid
    end

    it "can't have the same stock twice" do
      expect { @contest.stocks << @stocks.sample }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "doesn't destroy stock on destroy" do
      expect { @contest.destroy }.not_to change(Stock, :count)
    end

    it "doesn't destroy on destroy stock" do
      expect { @stocks.sample.destroy }.not_to change(Contest, :count)
    end
  end

  context 'with registered users' do
    before do
      @contest = create(:contest, :with_participants)
      @applications = @contest.contest_applications
    end

    it 'is valid' do
      expect(@contest).to be_valid
    end

    it "isn't valid if status changed to finished" do
      expect { @contest.status = Contest.statuses[:finished] }.to change(@contest, :valid?).to(false)
    end

    it 'can be transformed to finished' do
      expect do
        Contest.transaction do
          @contest.status = Contest.statuses[:finished]
          i = 1
          @applications.each do |application|
            application.final_position = i
            i += 1
            application.coins_delta = 1
            application.fantasy_points_delta = 1
            application.save!
          end
          @contest.save!
        end
      end.to_not raise_error
      expect(@contest).to be_valid
      @applications.each { |a| expect(a).to be_valid }
    end
  end

  it 'is valid with registered users and preconfigured stocks' do
    expect(create(:contest, :with_participants, :with_stocks)).to be_valid
  end

  it "isn't valid without reg ending timestamp" do
    expect { create :contest, reg_ending_at: nil }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without summarizing timestamp" do
    expect { create :contest, summarizing_at: nil }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid with negative coins entry fee" do
    expect { create :contest, coins_entry_fee: -Faker::Number.number.abs }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid with negative max fantasy points threshold" do
    expect do
      create :contest, max_fantasy_points_threshold: -Faker::Number.number.abs
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without direction strategy" do
    expect { create :contest, direction_strategy: nil }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without status" do
    expect { create :contest, status: nil }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "can't have fixed direction up if direction strategy isn't 'fixed'" do
    expect do
      create :contest, direction_strategy: Contest.direction_strategies[:free], fixed_direction_up: false
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "can have fixed direction up if direction strategy is 'fixed'" do
    direction_strategy = Contest.direction_strategies[:fixed]
    expect(create(:contest, direction_strategy: direction_strategy, fixed_direction_up: false)).to be_valid
  end

  context 'finished and with users' do
    before do
      @contest = create :contest, :with_participants, :finished
      @applications = @contest.contest_applications
    end

    it 'is valid' do
      expect(@contest).to be_valid
    end

    it "can't return status back" do
      expect { @contest.status = Contest.statuses[:created] }.to change(@contest, :valid?).to(false)
    end
  end
end
