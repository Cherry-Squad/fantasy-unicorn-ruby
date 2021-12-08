# frozen_string_literal: true

# Removes robinhood_id from Stock model
class RemoveRobinhoodIdFromStock < ActiveRecord::Migration[6.1]
  def change
    remove_column :stocks, :robinhood_id
  end
end
