# frozen_string_literal: true

# This class represents a User record
class User < ApplicationRecord
  validates :username, presence: true, length: { in: 3..25 }
  validates :email, presence: true
  validates :password, presence: true, length: { in: 4..255 }
  validates :preferred_lang, length: { in: 2..10 }
  validates :fantasy_points, numericality: { greater_than_or_equal_to: 0 }
  validates :coins, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_defaults

  def set_defaults
    self.email_validated ||= false
    self.preferred_lang ||= 'ru_RU'
    self.coins ||= 0
    self.fantasy_points ||= 0
  end
end