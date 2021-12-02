# frozen_string_literal: true

# This class represents a User record.
# The User model holds user info and credentials.
class User < ApplicationRecord
  has_many :achievements, dependent: :delete_all
  has_many :contest_applications, dependent: :destroy
  has_one :briefcase, dependent: :destroy

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

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  coins           :bigint           not null
#  email           :string(255)      not null
#  email_validated :boolean          not null
#  fantasy_points  :bigint           not null
#  password        :string(255)      not null
#  preferred_lang  :string(10)
#  username        :string(25)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  avatar_id       :integer
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_username  (username) UNIQUE
#
