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

ActiveRecord::Schema[7.0].define(version: 2025_12_19_165001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_menu_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "weight"
    t.integer "client_menu_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_menu_items", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "cost"
    t.string "quantity"
    t.integer "weight"
    t.integer "client_menu_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_menu_mailer_logs", force: :cascade do |t|
    t.integer "client_menu_id"
    t.string "email"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_menu_selections", force: :cascade do |t|
    t.integer "client_menu_submission_id"
    t.integer "client_menu_item_id"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_menu_submissions", force: :cascade do |t|
    t.integer "client_menu_id"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total"
    t.text "notes"
    t.text "staples_notes"
  end

  create_table "client_menus", force: :cascade do |t|
    t.integer "client_id"
    t.datetime "due_at", precision: nil
    t.text "message"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "job_date", precision: nil
    t.boolean "show_pricing", default: false
    t.boolean "staples_enabled", default: false
    t.text "staples_notes"
    t.boolean "is_kat", default: false
    t.integer "user_id"
    t.string "title"
    t.string "allergies"
  end

  create_table "clients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.integer "user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "neighborhood"
    t.string "event_date"
  end

  create_table "events", force: :cascade do |t|
    t.date "starts_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_applications", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "position"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meals", force: :cascade do |t|
    t.string "name"
    t.text "instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "menus", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "weight"
    t.integer "category_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staple_categories", force: :cascade do |t|
    t.string "name"
    t.integer "staple_id"
    t.integer "client_menu_id"
    t.integer "weight", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staple_selections", force: :cascade do |t|
    t.integer "staple_id"
    t.integer "client_menu_submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staples", force: :cascade do |t|
    t.string "name"
    t.integer "staple_category_id"
    t.integer "weight"
    t.boolean "selected", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "waitlists", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "neighborhood"
    t.string "start_date"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
