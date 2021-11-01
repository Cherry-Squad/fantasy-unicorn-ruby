# frozen_string_literal: true

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

  it 'must have unique username' do
    u = create :user
    expect do
      create :user, username: u.username
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'must have unique email' do
    u = create :user
    expect do
      create :user, email: u.email
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
