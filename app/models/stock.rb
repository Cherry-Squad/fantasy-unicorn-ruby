# frozen_string_literal: true

class Stock < ApplicationRecord
  has_and_belongs_to_many :briefcases
  before_destroy { briefcases.clear }

  validates :name, presence: true, length: { maximum: 16 }
  validates :robinhood_id, presence: true, format: {
    with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}\z/i,
    message: "provided robinhood_id isn't UUID"
  }
end
