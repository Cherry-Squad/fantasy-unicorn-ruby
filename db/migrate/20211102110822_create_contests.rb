# frozen_string_literal: true

# Creates Contest model and Contest-Stock many-to-many join table
class CreateContests < ActiveRecord::Migration[6.1]
  def change
    create_table :contests do |t|
      t.timestamp :reg_ending_at, null: false
      t.timestamp :summarizing_at, null: false
      t.string :status, null: false

      t.bigint :coins_entry_fee, null: false
      t.bigint :max_fantasy_points_threshold

      t.boolean :use_briefcase_only, null: false
      t.string :direction_strategy, null: false
      t.boolean :fixed_direction_up
      t.boolean :use_disabled_multipliers, null: false
      t.boolean :use_inverted_stock_prices, null: false

      t.timestamps
    end

    create_table :contest_preconfigured_stocks, id: false do |t|
      t.belongs_to :contest, null: false
      t.belongs_to :stock, null: false

      t.index %i[contest_id stock_id], unique: true
    end
  end
end
