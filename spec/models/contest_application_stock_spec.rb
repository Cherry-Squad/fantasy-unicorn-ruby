# frozen_string_literal: true

# == Schema Information
#
# Table name: contest_application_stocks
#
#  id                     :bigint           not null, primary key
#  final_price            :decimal(, )
#  multiplier             :decimal(, )      not null
#  reg_price              :decimal(, )      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  contest_application_id :bigint           not null
#  stock_id               :bigint           not null
#
# Indexes
#
#  cas_ca_id_stock_id                                          (contest_application_id,stock_id) UNIQUE
#  index_contest_application_stocks_on_contest_application_id  (contest_application_id)
#  index_contest_application_stocks_on_stock_id                (stock_id)
#
require 'rails_helper'

RSpec.describe ContestApplicationStock, type: :model do
  subject { create :contest_application_stock }
  let(:contest_application) { subject.contest_application }
  let(:contest) { contest_application.contest }
  let(:user) { contest_application.user }
  let(:stock) { subject.stock }
  let(:multiplier) { subject.multiplier }
  let(:reg_price) { subject.reg_price }
  let(:final_price) { subject.final_price }

  it 'is valid' do
    is_expected.to be_valid
  end

  it "isn't valid without a contest application" do
    subject.contest_application = nil
    is_expected.to_not be_valid
  end

  it "isn't valid without a stock" do
    subject.stock = nil
    is_expected.to_not be_valid
  end

  it "isn't valid without a multiplier" do
    subject.multiplier = nil
    is_expected.to_not be_valid
  end

  it "isn't valid with negative multiplier" do
    subject.multiplier = -multiplier
    is_expected.to_not be_valid
  end

  it "isn't valid without reg price" do
    subject.reg_price = nil
    is_expected.to_not be_valid
  end

  it "isn't valid with negative reg price" do
    subject.reg_price = -reg_price
    is_expected.to_not be_valid
  end

  it "isn't valid if contest status == finished and without final price" do
    contest.status = Contest.statuses[:reg_ended]
    is_expected.not_to be_valid
  end

  context 'with a final price' do
    subject { create :contest_application_stock, :with_final_price }

    it 'is valid' do
      is_expected.to be_valid
    end

    it "isn't valid with negative final price" do
      subject.final_price = -final_price
      is_expected.not_to be_valid
    end

    it "isn't valid if contest status != finished" do
      contest.status = Contest.statuses[:reg_ended]
      is_expected.not_to be_valid
    end
  end

  context 'with variable multiplier' do
    subject { create :contest_application_stock, :with_variable_multiplier }

    it 'is valid' do
      is_expected.to be_valid
    end
  end

  it "can't share the same stock on one contest application" do
    expect { create :contest_application_stock, stock: stock, contest_application: contest_application }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'can share the same stock on separate contest applications' do
    expect(create(:contest_application_stock, stock: stock)).to be_valid
  end

  it "isn't destroy the stock" do
    expect { subject.destroy }.to_not change { Stock.exists?(id: stock.id) }.from(true)
  end

  it "isn't destroy the contest application" do
    expect { subject.destroy }.to_not change { ContestApplication.exists?(id: contest_application.id) }.from(true)
  end

  it 'is destroyed with the contest application' do
    expect { contest_application.destroy }.to change { ContestApplicationStock.exists?(id: subject.id) }
                                                .from(true).to(false)
  end

  it 'is destroyed with the stock' do
    expect { stock.destroy }.to change { ContestApplicationStock.exists?(id: subject.id) }
                                  .from(true).to(false)
  end

  it 'is destroyed with the user' do
    expect { user.destroy }.to change { ContestApplicationStock.exists?(id: subject.id) }
                                 .from(true).to(false)
  end

  it 'is destroyed with the contest' do
    expect { contest.destroy }.to change { ContestApplicationStock.exists?(id: subject.id) }
                                    .from(true).to(false)
  end
end
