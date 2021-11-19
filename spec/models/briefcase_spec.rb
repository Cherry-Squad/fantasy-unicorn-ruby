# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Briefcase, type: :model do
  it 'is valid with valid parameters' do
    expect(create(:briefcase)).to be_valid
  end

  it 'is valid with stocks' do
    expect(create(:briefcase, :with_stocks)).to be_valid
  end

  it "isn't valid without user" do
    expect { create :briefcase, user_id: nil }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid without expired" do
    expect { create :briefcase, expiring_at: nil }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "isn't valid if stocks count exceeds maximum" do
    stocks_count = Briefcase::BRIEFCASE_STOCKS_MAX_COUNT + 1
    expect { create :briefcase, :with_stocks, stock_count: stocks_count }.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'created with default parameters' do
    before do
      @briefcase = create :briefcase, :with_stocks
      @user = @briefcase.user
      @stocks = @briefcase.stocks
    end

    it 'must be unique per user' do
      expect { create :briefcase, user: @user }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'is destroyed along with the user' do
      expect { @user.destroy }.to change { Briefcase.exists?(id: @briefcase.id) }.from(true).to(false)
    end

    it "isn't destroy along with the stock" do
      expect { @stocks.sample.destroy }.not_to change { Briefcase.exists?(id: @briefcase.id) }.from(true)
    end

    it "isn't destroy the owner when called destroy" do
      expect { @briefcase.destroy }.not_to change { User.exists?(id: @user.id) }.from(true)
    end

    it "isn't destroy the stocks when called destroy" do
      expect { @briefcase.destroy }.not_to change(Stock, :count)
    end

    it "can't have the same stock twice" do
      expect { @briefcase.stocks.append(@stocks.sample) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
