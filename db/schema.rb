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

ActiveRecord::Schema[8.0].define(version: 2025_07_26_185051) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "customer_id"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.string "customer_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "employee_id"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "department"
    t.string "position"
    t.date "hire_date"
    t.decimal "salary"
    t.string "status"
    t.integer "supervisor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employees_on_employee_id", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "product_id"
    t.string "name"
    t.text "description"
    t.string "category"
    t.string "material"
    t.decimal "weight"
    t.decimal "cost_price"
    t.decimal "selling_price"
    t.integer "stock_quantity"
    t.integer "minimum_stock"
    t.string "supplier"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "role"
    t.bigint "employee_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_users_on_employee_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "employees", "employees", column: "supervisor_id"
  add_foreign_key "users", "employees"
end
