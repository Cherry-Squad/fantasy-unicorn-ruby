# frozen_string_literal: true

# == Schema Information
#
# Table name: stocks
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  robinhood_id :string           not null
#
# Indexes
#
#  index_stocks_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe Stock, type: :model do
  subject { create(:stock) }
  let(:name) { subject.name }

  it 'is valid with valid arguments' do
    is_expected.to be_valid
  end

  it "isn't valid without name" do
    subject.name = nil
    is_expected.to_not be_valid
  end

  it "isn't valid without robinhood id" do
    subject.robinhood_id = nil
    is_expected.to_not be_valid
  end

  it "isn't valid if name is too long" do
    subject.name = Faker::String.random(length: 40)
    is_expected.to_not be_valid
  end

  it "isn't valid if robinhood id isn't UUID" do
    subject.robinhood_id = Faker::String.random(length: 35)
    is_expected.to_not be_valid
  end

  it 'must have unique name' do
    expect do
      create :stock, name: name
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
