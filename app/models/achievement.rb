# frozen_string_literal: true

# This class represents an Achievement record.
# The Achievement model represents an achievement obtained by a User.
#
# User < Achievement: many-to-one, unique achievement_identifier per user_id
class Achievement < ApplicationRecord
  belongs_to :user

  validates_presence_of :user, :achievement_identifier
end

# == Schema Information
#
# Table name: achievements
#
#  id                     :bigint           not null, primary key
#  achievement_identifier :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint
#
# Indexes
#
#  index_achievements_on_user_id                             (user_id)
#  index_achievements_on_user_id_and_achievement_identifier  (user_id,achievement_identifier) UNIQUE
#
