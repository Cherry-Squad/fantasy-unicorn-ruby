# frozen_string_literal: true

# Creates CreateContestApplicationStocks model
class CreateContestApplicationStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :contest_application_stocks do |t|
      t.belongs_to :contest_application, null: false
      t.belongs_to :stock, null: false
      t.decimal :multiplier, null: false
      t.decimal :reg_price
      t.decimal :final_price

      t.index %i[contest_application_id stock_id], name: 'cas_ca_id_stock_id', unique: true
      t.timestamps
    end
  end
end
