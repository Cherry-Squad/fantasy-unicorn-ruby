# frozen_string_literal: true

# This class represents a ContestApplicationStock record.
# The ContestApplicationStock holds a registered stock bet
# on ContestApplication and some meta-info.
#
# ContestApplication < ContestApplicationStock: many-to-one
# Stock < ContestApplicationStock: many-to-one
class ContestApplicationStock < ApplicationRecord
  belongs_to :contest_application
  belongs_to :stock

  validates :multiplier, numericality: { greater_than: 0 }
  validates :reg_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :reg_price, presence: true, unless: -> { final_price.nil? }
  validates :final_price, numericality: { greater_than: 0 }, presence: true, if: :contest_status_is_finished
  validates :final_price, absence: true, if: :contest_status_is_not_finished

  private

  def contest_status_is_finished
    return false if contest_application.nil? || contest_application.contest.nil?

    contest_application.contest.status == Contest.statuses[:finished]
  end

  def contest_status_is_not_finished
    return false if contest_application.nil? || contest_application.contest.nil?

    contest_application.contest.status != Contest.statuses[:finished]
  end
end

# == Schema Information
#
# Table name: contest_application_stocks
#
#  id                     :bigint           not null, primary key
#  final_price            :decimal(8, 4)
#  multiplier             :decimal(4, 2)    not null
#  reg_price              :decimal(8, 4)
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
