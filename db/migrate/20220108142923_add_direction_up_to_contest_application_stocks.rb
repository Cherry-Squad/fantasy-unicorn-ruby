# frozen_string_literal: true

# add direction_up field to ContestApplicationStocks
class AddDirectionUpToContestApplicationStocks < ActiveRecord::Migration[6.1]
  def change
    add_column :contest_application_stocks, :direction_up, :boolean
  end
end
