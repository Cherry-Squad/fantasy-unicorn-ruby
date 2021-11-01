# frozen_string_literal: true

# Creates User model
class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, null: false, limit: 25, index: { unique: true }
      t.string :email, null: false, limit: 255, index: { unique: true }
      t.string :password, null: false, limit: 255
      t.boolean :email_validated, null: false
      t.string :preferred_lang, limit: 10
      t.integer :avatar_id
      t.integer :coins, null: false
      t.integer :fantasy_points, null: false

      t.timestamps
    end
  end
end