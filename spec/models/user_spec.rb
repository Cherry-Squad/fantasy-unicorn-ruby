# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }
  let(:username) { subject.username }
  let(:email) { subject.email }

  it 'is valid with valid arguments' do
    is_expected.to be_valid
  end

  it "isn't valid without username" do
    subject.username = nil
    is_expected.to_not be_valid
  end

  it "isn't valid without email" do
    subject.email = nil
    is_expected.to_not be_valid
  end

  it "isn't valid without password" do
    subject.password = nil
    is_expected.to_not be_valid
  end

  it "isn't valid if username is too big" do
    subject.username = Faker::Internet.username(specifier: 30..40)
    is_expected.to_not be_valid
  end

  it "isn't valid if password is too big" do
    subject.username = Faker::Internet.password(min_length: 300)
    is_expected.to_not be_valid
  end

  it "isn't valid if preferred lang is too big" do
    subject.preferred_lang = Faker::String.random(length: 15)
    is_expected.to_not be_valid
  end

  it "isn't valid if coins are below zero" do
    subject.coins = -Faker::Number.number.abs
    is_expected.to_not be_valid
  end

  it "isn't valid if fantasy points are below zero" do
    subject.fantasy_points = -Faker::Number.number.abs
    is_expected.to_not be_valid
  end

  it 'must have unique username' do
    expect do
      create :user, username: username
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'must have unique email' do
    expect do
      create :user, email: email
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  context 'created with points' do
    subject { create(:user_with_points) }

    it 'is valid' do
      is_expected.to be_valid
    end
  end
end
