# frozen_string_literal: true

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
    expect { user.destroy }.to change(subject, :exists).to(false)
  end

  it "doesn't destroy owner on destroy" do
    expect { achievement.destroy }.not_to change(user, :exists).to(false)
  end
end
