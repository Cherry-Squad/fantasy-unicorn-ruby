# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  coins                  :bigint           not null
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string(255)      not null
#  email_validated        :boolean          not null
#  encrypted_password     :string(255)      not null
#  fantasy_points         :bigint           not null
#  preferred_lang         :string(10)
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  username               :string(25)       not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  avatar_id              :integer
#
# Indexes
#
#  index_users_on_email             (email) UNIQUE
#  index_users_on_uid_and_provider  (uid,provider) UNIQUE
#  index_users_on_username          (username) UNIQUE
#
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

  #it "isn't valid without password" do
    #subject.password = nil
    #is_expected.to_not be_valid
  #end

  it "isn't valid if username is too big" do
    subject.username = Faker::Internet.username(specifier: 30..40)
    is_expected.to_not be_valid
  end

  #it "isn't valid if password is too big" do
    #subject.password = Faker::Internet.password(min_length: 300)
    #is_expected.to_not be_valid
  #end

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
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'created with points' do
    subject { create(:user_with_points) }

    it 'is valid' do
      is_expected.to be_valid
    end
  end
end
