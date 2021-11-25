# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contest, type: :model do
  subject { create(:contest) }

  it 'is valid with valid arguments' do
    is_expected.to be_valid
  end

  context 'created with preconfigured stocks' do
    subject { create(:contest, :with_stocks) }
    let(:stocks) { subject.stocks }

    it 'is valid' do
      is_expected.to be_valid
    end

    it "can't have the same stock twice" do
      expect { subject.stocks << stocks.sample }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "doesn't destroy stock on destroy" do
      expect { subject.destroy }.not_to change(Stock, :count).from(stocks.size)
    end

    it "doesn't destroy on destroy stock" do
      expect { stocks.sample.destroy }.not_to change { Contest.exists?(id: subject.id) }.from(true)
    end
  end

  context 'created with registered users' do
    subject { create(:contest, :with_participants) }
    let(:applications) { subject.contest_applications }

    it 'is valid' do
      is_expected.to be_valid
    end

    it "isn't valid if status changed to finished" do
      expect { subject.status = Contest.statuses[:finished] }.to change(subject, :valid?).to(false)
    end

    context 'transformable to finished' do
      before { transform }

      def transform
        subject.status = Contest.statuses[:finished]
        i = 1
        applications.each do |application|
          application.final_position = i
          i += 1
          application.coins_delta = 1
          application.fantasy_points_delta = 1
          application.save!
        end
        subject.save!
      end

      it 'and contest would be still valid' do
        is_expected.to be_valid
      end

      it 'and all stocks are valid' do
        applications.each { |a| expect(a).to be_valid }
      end
    end
  end

  context 'created with registered users and preconfigured stocks' do
    subject { create(:contest, :with_participants, :with_stocks) }

    it 'is valid' do
      is_expected.to be_valid
    end
  end

  it "isn't valid without reg ending timestamp" do
    subject.reg_ending_at = nil
    is_expected.to_not be_valid
  end

  it "isn't valid without summarizing timestamp" do
    subject.summarizing_at = nil
    is_expected.to_not be_valid
  end

  it "isn't valid with negative coins entry fee" do
    subject.coins_entry_fee = -Faker::Number.number.abs
    is_expected.to_not be_valid
  end

  it "isn't valid with negative max fantasy points threshold" do
    subject.max_fantasy_points_threshold = -Faker::Number.number.abs
    is_expected.to_not be_valid
  end

  it "isn't valid without direction strategy" do
    subject.direction_strategy = nil
    is_expected.to_not be_valid
  end

  it "isn't valid without status" do
    subject.status = nil
    is_expected.to_not be_valid
  end

  it "can't have fixed direction up if direction strategy isn't 'fixed'" do
    subject.direction_strategy = Contest.direction_strategies[:free]
    subject.fixed_direction_up = false
    is_expected.to_not be_valid
  end

  it "can have fixed direction up if direction strategy is 'fixed'" do
    subject.direction_strategy = Contest.direction_strategies[:fixed]
    subject.fixed_direction_up = false
    is_expected.to be_valid
  end

  context 'finished and with users' do
    subject { create(:contest, :with_participants, :finished) }
    let(:applications) { subject.contest_applications }

    it 'is valid' do
      is_expected.to be_valid
    end
    it "can't return status back" do
      expect { subject.status = Contest.statuses[:created] }.to change(subject, :valid?).to(false)
    end
  end
end
