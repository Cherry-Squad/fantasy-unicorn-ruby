# frozen_string_literal: true

# Creates Achievement model
class CreateAchievements < ActiveRecord::Migration[6.1]
  def change
    create_table :achievements do |t|
      t.references :user
      t.integer :achievement_identifier
      t.index %i[user_id achievement_identifier], unique: true

      t.timestamps
    end
  end
end
