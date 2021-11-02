# frozen_string_literal: true

# Creates Briefcase model and many-to-many join table
# between Briefcase and Stock
class CreateBriefcases < ActiveRecord::Migration[6.1]
  def change
    create_table :briefcases do |t|
      t.timestamp :expiring_at, null: false
      t.references :user, index: { unique: true }, null: false

      t.timestamps
    end

    create_table :briefcases_stocks, id: false do |t|
      t.belongs_to :briefcase
      t.belongs_to :stock
    end
  end
end
