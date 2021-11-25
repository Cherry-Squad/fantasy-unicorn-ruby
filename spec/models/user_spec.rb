# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  coins           :bigint           not null
#  email           :string(255)      not null
#  email_validated :boolean          not null
#  fantasy_points  :bigint           not null
#  password        :string(255)      not null
#  preferred_lang  :string(10)
#  username        :string(25)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  avatar_id       :integer
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_username  (username) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'valid with valid attributes' do
    expect(create(:user_with_points)).to be_valid
  end

  it 'valid with only necessary attributes' do
    expect(create(:user)).to be_valid
  end

  it "isn't valid without username" do
    expect do
      create :user, username: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without email" do
    expect do
      create :user, email: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without password" do
    expect do
      create :user, password: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if username is too big" do
    expect do
      create :user, username: Faker::Internet.username(specifier: 30..40)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if password is too big" do
    expect do
      create :user, password: Faker::Internet.password(min_length: 300)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if preferred lang is too big" do
    expect do
      create :user, preferred_lang: Faker::String.random(length: 15)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if coins are below zero" do
    expect do
      create :user, coins: -Faker::Number.number.abs
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if fantasy points are below zero" do
    expect do
      create :user, fantasy_points: -Faker::Number.number.abs
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'created with default parametes' do
    before do
      @user = create :user
    end

    it 'must have unique username' do
      expect do
        create :user, username: @user.username
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'must have unique email' do
      expect do
        create :user, email: @user.email
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
