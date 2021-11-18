# frozen_string_literal: true

# This class represents a Briefcase record.
# The Briefcase model holds a set of Stocks per User.
#
# User - Briefcase: one-to-one, unique
# Stock >< Briefcase: many-to-many
class Briefcase < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :stocks
  before_destroy { stocks.clear }

  BRIEFCASE_STOCKS_MAX_COUNT = 10

  validates :user, presence: true
  validates :expiring_at, presence: true
  validates :stocks, length: { maximum: BRIEFCASE_STOCKS_MAX_COUNT }
end
