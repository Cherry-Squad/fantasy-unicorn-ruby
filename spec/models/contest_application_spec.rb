# frozen_string_literal: true

# == Schema Information
#
# Table name: contest_applications
#
#  id                   :bigint           not null, primary key
#  coins_delta          :bigint
#  fantasy_points_delta :bigint
#  final_position       :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  contest_id           :bigint           not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_contest_applications_on_contest_id                     (contest_id)
#  index_contest_applications_on_contest_id_and_final_position  (contest_id,final_position) UNIQUE
#  index_contest_applications_on_user_id                        (user_id)
#  index_contest_applications_on_user_id_and_contest_id         (user_id,contest_id) UNIQUE
#
require 'rails_helper'

RSpec.describe ContestApplication, type: :model do
  context 'with minimum attributes' do
    before do
      @application = create :contest_application
      @user = @application.user
      @contest = @application.contest
    end

    it 'is valid' do
      expect(@application).to be_valid
    end

    it 'is destroyed together with the user' do
      expect { @user.destroy }.to change(ContestApplication, :count).from(1).to(0)
    end

    it 'is destroyed together with the contest' do
      expect { @application.destroy }.to change(ContestApplication, :count).from(1).to(0)
    end

    it "isn't destroy the user" do
      expect { @application.destroy }.not_to change(User, :count).from(1)
    end

    it "isn't destroy the contest" do
      expect { @application.destroy }.not_to change(Contest, :count).from(1)
    end

    it "can't duplicate contest-user pair" do
      expect do
        create :contest_application, contest: @contest, user: @user
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "isn't valid if contest status == finished" do
      expect { @contest.status = Contest.statuses[:finished] }.to change(@application, :valid?).from(true).to(false)
    end
  end

  context 'with finish data' do
    before do
      @application = create :contest_application, :with_results
      @user = @application.user
      @contest = @application.contest
    end

    it 'is valid' do
      expect(@application).to be_valid
    end

    it "isn't valid if contest status != finished" do
      expect { @contest.status = Contest.statuses[:created] }.to change(@application, :valid?).from(true).to(false)
    end

    it "can't share position within the same contest" do
      expect do
        create :contest_application, :with_results,
               user: @user, contest: @contest, final_position: @application.final_position
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'can share position on separate contests' do
      expect(
        create(:contest_application, :with_results,
               user: @user, final_position: @application.final_position)
      ).to be_valid
    end
  end
end
