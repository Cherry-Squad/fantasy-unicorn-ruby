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
  subject { create :contest_application }
  let(:user) { subject.user }
  let(:contest) { subject.contest }

  it 'is valid with valid arguments' do
    is_expected.to be_valid
  end

  it 'is destroyed together with the user' do
    expect { user.destroy }.to change { ContestApplication.exists?(id: subject.id) }.from(true)
  end

  it 'is destroyed together with the contest' do
    expect { subject.destroy }.to change { ContestApplication.exists?(id: subject.id) }.from(true)
  end

  it "isn't destroy the user" do
    expect { subject.destroy }.not_to change { User.exists?(id: user.id) }.from(true)
  end

  it "isn't destroy the contest" do
    expect { subject.destroy }.not_to change { Contest.exists?(id: contest.id) }.from(true)
  end

  it "can't duplicate contest-user pair" do
    expect do
      create :contest_application, contest: contest, user: user
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "isn't valid if contest status == finished" do
    expect { contest.status = Contest.statuses[:finished] }.to change(subject, :valid?).from(true).to(false)
  end

  context 'created with finish data' do
    subject { create :contest_application, :with_results }
    let(:final_position) { subject.final_position }

    it 'is valid' do
      is_expected.to be_valid
    end

    it "isn't valid if contest status != finished" do
      expect { contest.status = Contest.statuses[:created] }.to change(subject, :valid?).from(true).to(false)
    end

    it "can't share position within the same contest" do
      expect do
        create :contest_application, :with_results,
               user: user, contest: contest, final_position: final_position
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'can share position on separate contests' do
      expect(
        create(:contest_application, :with_results,
               user: user, final_position: final_position)
      ).to be_valid
    end
  end
end
