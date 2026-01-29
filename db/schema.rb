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

ActiveRecord::Schema[7.1].define(version: 20_240_101_000_003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'items', force: :cascade do |t|
    t.string 'name', null: false
    t.text 'description'
    t.string 'category'
    t.decimal 'price', precision: 10, scale: 2
    t.integer 'quantity', default: 0
    t.boolean 'active', default: true, null: false
    t.bigint 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['active'], name: 'index_items_on_active'
    t.index ['category'], name: 'index_items_on_category'
    t.index ['user_id'], name: 'index_items_on_user_id'
  end

  create_table 'report_data', force: :cascade do |t|
    t.string 'report_type', null: false
    t.date 'date', null: false
    t.jsonb 'data', default: {}, null: false
    t.jsonb 'metadata', default: {}
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['date'], name: 'index_report_data_on_date'
    t.index %w[report_type date], name: 'index_report_data_on_report_type_and_date', unique: true
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', null: false
    t.string 'password_digest', null: false
    t.string 'name', null: false
    t.string 'role', default: 'user', null: false
    t.boolean 'active', default: true, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['role'], name: 'index_users_on_role'
  end

  add_foreign_key 'items', 'users'
end
