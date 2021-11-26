# frozen_string_literal: true

# == Schema Information
#
# Table name: achievements
#
#  id                     :bigint           not null, primary key
#  achievement_identifier :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint
#
# Indexes
#
#  index_achievements_on_user_id                             (user_id)
#  index_achievements_on_user_id_and_achievement_identifier  (user_id,achievement_identifier) UNIQUE
#
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  subject { create :achievement }
  let(:user) { subject.user }
  let(:achievement_identifier) { subject.achievement_identifier }
  let(:id) { subject.id }

  it 'is valid with valid arguments' do
    is_expected.to be_valid
  end

  it "isn't valid without user id" do
    subject.user = nil
    is_expected.to_not be_valid
  end

  it "isn't valid without achievement identifier" do
    subject.achievement_identifier = nil
    is_expected.to_not be_valid
  end

  it 'must have unique achievement identifier per user' do
    expect do
      create :achievement, user: user, achievement_identifier: achievement_identifier
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'can share achievement identifier with other users' do
    expect do
      create :achievement, achievement_identifier: achievement_identifier
    end.to_not raise_error
  end

  it 'destroyed together with the user' do
    expect { user.destroy }.to change { Achievement.exists?(id: subject.id) }.to(false)
  end

  it "doesn't destroy owner on destroy" do
    expect { subject.destroy }.not_to(change { User.exists?(id: user.id) })
  end
end
