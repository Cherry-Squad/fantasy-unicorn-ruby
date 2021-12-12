# frozen_string_literal: true

# This class represents a User record.
# The User model holds user info and credentials.
class User < ApplicationRecord
  extend Devise::Models
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # :confirmable

  has_many :achievements, dependent: :delete_all
  has_many :contest_applications, dependent: :destroy
  has_one :briefcase, dependent: :destroy

  validates :username, presence: true, length: { in: 3..25 }
  validates :email, presence: true
  # validates :password, presence: true, length: { in: 4..255 }
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

  include DeviseTokenAuth::Concerns::User
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  coins                  :bigint           not null
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string(255)      not null
#  email_validated        :boolean          not null
#  encrypted_password     :string(255)      not null
#  fantasy_points         :bigint           not null
#  preferred_lang         :string(10)
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  username               :string(25)       not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  avatar_id              :integer
#
# Indexes
#
#  index_users_on_email             (email) UNIQUE
#  index_users_on_uid_and_provider  (uid,provider) UNIQUE
#  index_users_on_username          (username) UNIQUE
#
