# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Briefcase, type: :model do
  it 'is valid with valid parameters' do
    expect(create(:briefcase)).to be_valid
  end

  it 'is valid with stocks' do
    expect(create(:briefcase_with_stocks)).to be_valid
  end

  it "isn't valid without user" do
    expect do
      create :briefcase, user_id: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without expired" do
    expect do
      create :briefcase, expiring_at: nil
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if stocks count exceeds maximum" do
    expect do
      create :briefcase_with_stocks, stocks_count: Briefcase::BRIEFCASE_STOCKS_MAX_COUNT + 1
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'created with default parameters' do
    before do
      @briefcase = create :briefcase_with_stocks
      @user = @briefcase.user
      @stocks = @briefcase.stocks
    end

    it 'must be unique per user' do
      expect do
        create :briefcase, user: @user
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'is destroyed along with the user' do
      @user.destroy
      expect(Briefcase.where(id: @briefcase.id)).to_not be_present
    end

    it "isn't destroy along with the stock" do
      @stocks[0].destroy
      expect(Briefcase.where(id: @briefcase.id)).to be_present
    end

    it "isn't destroy the owner when called destroy" do
      @briefcase.destroy
      expect(Briefcase.where(id: @briefcase.id)).to_not be_present
    end

    it "isn't destroy the stocks when called destroy" do
      stocks_length = @stocks.length
      @briefcase.destroy
      expect(Stock.count).to eq(stocks_length)
    end
  end
end
