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

ActiveRecord::Schema.define(version: 2021_12_12_105924) do

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

  create_table "contest_application_stocks", force: :cascade do |t|
    t.bigint "contest_application_id", null: false
    t.bigint "stock_id", null: false
    t.decimal "multiplier", precision: 4, scale: 2, null: false
    t.decimal "reg_price", precision: 8, scale: 4
    t.decimal "final_price", precision: 8, scale: 4
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contest_application_id", "stock_id"], name: "cas_ca_id_stock_id", unique: true
    t.index ["contest_application_id"], name: "index_contest_application_stocks_on_contest_application_id"
    t.index ["stock_id"], name: "index_contest_application_stocks_on_stock_id"
  end

  create_table "contest_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "contest_id", null: false
    t.integer "final_position"
    t.bigint "coins_delta"
    t.bigint "fantasy_points_delta"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contest_id", "final_position"], name: "index_contest_applications_on_contest_id_and_final_position", unique: true
    t.index ["contest_id"], name: "index_contest_applications_on_contest_id"
    t.index ["user_id", "contest_id"], name: "index_contest_applications_on_user_id_and_contest_id", unique: true
    t.index ["user_id"], name: "index_contest_applications_on_user_id"
  end

  create_table "contest_preconfigured_stocks", id: false, force: :cascade do |t|
    t.bigint "contest_id", null: false
    t.bigint "stock_id", null: false
    t.index ["contest_id", "stock_id"], name: "index_contest_preconfigured_stocks_on_contest_id_and_stock_id", unique: true
    t.index ["contest_id"], name: "index_contest_preconfigured_stocks_on_contest_id"
    t.index ["stock_id"], name: "index_contest_preconfigured_stocks_on_stock_id"
  end

  create_table "contests", force: :cascade do |t|
    t.datetime "reg_ending_at", null: false
    t.datetime "summarizing_at", null: false
    t.string "status", null: false
    t.bigint "coins_entry_fee", null: false
    t.bigint "max_fantasy_points_threshold"
    t.boolean "use_briefcase_only", null: false
    t.string "direction_strategy", null: false
    t.boolean "fixed_direction_up"
    t.boolean "use_disabled_multipliers", null: false
    t.boolean "use_inverted_stock_prices", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_stocks_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", limit: 25, null: false
    t.string "email", limit: 255, null: false
    t.string "encrypted_password", limit: 255, null: false
    t.boolean "email_validated", null: false
    t.string "preferred_lang", limit: 10
    t.integer "avatar_id"
    t.bigint "coins", null: false
    t.bigint "fantasy_points", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
