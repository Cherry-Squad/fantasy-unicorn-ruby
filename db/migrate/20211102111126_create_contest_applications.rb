# frozen_string_literal: true

# Creates ContestApplication model
class CreateContestApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :contest_applications do |t|
      t.belongs_to :user, null: false
      t.belongs_to :contest, null: false
      t.integer :final_position
      t.bigint :coins_delta
      t.bigint :fantasy_points_delta

      t.index %i[user_id contest_id], unique: true
      t.index %i[contest_id final_position], unique: true
      t.timestamps
    end
  end
end
