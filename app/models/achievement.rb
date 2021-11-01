# frozen_string_literal: true

class Achievement < ApplicationRecord
  belongs_to :user

  validates_presence_of :user, :achievement_identifier
end
