# frozen_string_literal: true

# Creates Stock model
class CreateStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :stocks do |t|
      # looks like it's impossible to make a string primary key (https://stackoverflow.com/questions/1200568)
      t.string :name, null: false, index: { unique: true }
      t.string :robinhood_id, null: false

      t.timestamps
    end
  end
end
