# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Achievement, type: :model do
  it 'valid with valid arguments' do
    expect(create(:achievement)).to be_valid
  end

  it "isn't valid without user id" do
    expect do
      create :achievement, user_id: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without achievement identifier" do
    expect do
      create :achievement, achievement_identifier: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'created with default parameters' do
    before do
      @achievement = create :achievement
      @user = @achievement.user
    end

    it 'must have unique achievement identifier per user' do
      expect do
        create :achievement, user: @achievement.user, achievement_identifier: @achievement.achievement_identifier
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'can share achievement identifier with other users' do
      expect do
        create :achievement, achievement_identifier: @achievement.achievement_identifier
      end.to_not raise_error
    end

    it 'destroyed together with the user' do
      @user.destroy
      expect(Achievement.where(id: @achievement.id)).to_not be_present
    end

    it "doesn't destroy owner on destroy" do
      @achievement.destroy
      expect(User.where(id: @user.id)).to be_present
    end
  end
end
