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
  it 'valid with valid arguments' do
    expect(create(:stock)).to be_valid
  end

  it "isn't valid without name" do
    expect do
      create :stock, name: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without robinhood id" do
    expect do
      create :stock, robinhood_id: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if name is too long" do
    expect do
      create :stock, name: Faker::String.random(length: 40)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if robinhood id isn't UUID" do
    expect do
      create :stock, robinhood_id: Faker::String.random(length: 35)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'must have unique name' do
    s = create :stock
    expect do
      create :stock, name: s.name
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
