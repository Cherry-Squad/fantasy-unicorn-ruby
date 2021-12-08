# frozen_string_literal: true

# This class represents a Stock record.
# The Stock model holds only the stock info.
class Stock < ApplicationRecord
  has_and_belongs_to_many :briefcases
  has_many :contest_application_stocks, dependent: :delete_all
  before_destroy { briefcases.clear }

  validates :name, presence: true, length: { maximum: 16 }
end

# == Schema Information
#
# Table name: stocks
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stocks_on_name  (name) UNIQUE
#
