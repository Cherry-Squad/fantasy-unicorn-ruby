# frozen_string_literal: true

# This class represents a Stock record.
# The Stock model holds stock info and its id on stock exchanges like Robinhood.
class Stock < ApplicationRecord
  has_and_belongs_to_many :briefcases
  has_many :contest_application_stocks, dependent: :delete_all
  before_destroy { briefcases.clear }

  validates :name, presence: true, length: { maximum: 16 }
  validates :robinhood_id, presence: true, format: {
    with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}\z/i,
    message: "provided robinhood_id isn't UUID"
  }
end

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
