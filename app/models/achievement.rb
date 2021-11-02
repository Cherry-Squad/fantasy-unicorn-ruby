# frozen_string_literal: true

# This class represents an Achievement record.
# The Achievement model represents an achievement obtained by a User.
#
# User < Achievement: many-to-one, unique achievement_identifier per user_id
class Achievement < ApplicationRecord
  belongs_to :user

  validates_presence_of :user, :achievement_identifier
end
