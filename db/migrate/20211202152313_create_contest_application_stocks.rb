# frozen_string_literal: true

# Creates CreateContestApplicationStocks model
class CreateContestApplicationStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :contest_application_stocks do |t|
      t.belongs_to :contest_application, null: false
      t.belongs_to :stock, null: false
      t.decimal :multiplier, precision: 4, scale: 2, null: false
      t.decimal :reg_price, precision: 8, scale: 4
      t.decimal :final_price, precision: 8, scale: 4

      t.index %i[contest_application_id stock_id], name: 'cas_ca_id_stock_id', unique: true
      t.timestamps
    end
  end
end
