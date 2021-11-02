# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_11_01_215409) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "achievement_identifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "achievement_identifier"], name: "index_achievements_on_user_id_and_achievement_identifier", unique: true
    t.index ["user_id"], name: "index_achievements_on_user_id"
  end

  create_table "briefcases", force: :cascade do |t|
    t.datetime "expiring_at", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_briefcases_on_user_id", unique: true
  end

  create_table "briefcases_stocks", id: false, force: :cascade do |t|
    t.bigint "briefcase_id"
    t.bigint "stock_id"
    t.index ["briefcase_id", "stock_id"], name: "index_briefcases_stocks_on_briefcase_id_and_stock_id", unique: true
    t.index ["briefcase_id"], name: "index_briefcases_stocks_on_briefcase_id"
    t.index ["stock_id"], name: "index_briefcases_stocks_on_stock_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "name", null: false
    t.string "robinhood_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_stocks_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", limit: 25, null: false
    t.string "email", limit: 255, null: false
    t.string "password", limit: 255, null: false
    t.boolean "email_validated", null: false
    t.string "preferred_lang", limit: 10
    t.integer "avatar_id"
    t.bigint "coins", null: false
    t.bigint "fantasy_points", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
