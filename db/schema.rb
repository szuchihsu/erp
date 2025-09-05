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

ActiveRecord::Schema[8.0].define(version: 2025_09_05_125510) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bill_of_materials", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "version", default: "1.0"
    t.text "description"
    t.boolean "is_active", default: true
    t.date "effective_date"
    t.date "obsolete_date"
    t.decimal "total_cost", precision: 10, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_bill_of_materials_on_is_active"
    t.index ["product_id", "version"], name: "index_bill_of_materials_on_product_id_and_version", unique: true
    t.index ["product_id"], name: "index_bill_of_materials_on_product_id"
  end

  create_table "bom_items", force: :cascade do |t|
    t.bigint "bill_of_material_id", null: false
    t.bigint "material_id", null: false
    t.decimal "quantity", precision: 10, scale: 4, null: false
    t.string "unit_of_measure", default: "gram"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.decimal "total_cost", precision: 10, scale: 2
    t.text "notes"
    t.integer "sequence_number"
    t.boolean "is_optional", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_of_material_id"], name: "index_bom_items_on_bill_of_material_id"
    t.index ["material_id"], name: "index_bom_items_on_material_id"
  end

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

  create_table "design_images", force: :cascade do |t|
    t.bigint "design_request_id", null: false
    t.string "image_path"
    t.string "image_type"
    t.text "description"
    t.boolean "is_final"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_request_id"], name: "index_design_images_on_design_request_id"
  end

  create_table "design_requests", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "sales_order_id"
    t.text "design_details"
    t.string "status"
    t.string "priority"
    t.datetime "requested_date"
    t.datetime "completed_date"
    t.bigint "assigned_designer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_designer_id"], name: "index_design_requests_on_assigned_designer_id"
    t.index ["customer_id"], name: "index_design_requests_on_customer_id"
    t.index ["sales_order_id"], name: "index_design_requests_on_sales_order_id"
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

  create_table "inventory_adjustments", force: :cascade do |t|
    t.string "adjustment_type"
    t.integer "quantity"
    t.string "reason"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "inventoryable_type"
    t.bigint "inventoryable_id"
    t.string "item_type"
    t.bigint "item_id"
    t.index ["inventoryable_type", "inventoryable_id"], name: "idx_on_inventoryable_type_inventoryable_id_03f38916c5"
    t.index ["item_type", "item_id"], name: "index_inventory_adjustments_on_item_type_and_item_id"
    t.index ["user_id"], name: "index_inventory_adjustments_on_user_id"
  end

  create_table "inventory_transactions", force: :cascade do |t|
    t.string "transaction_type"
    t.integer "quantity"
    t.string "reference_type"
    t.integer "reference_id"
    t.text "notes"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "inventoryable_type"
    t.bigint "inventoryable_id"
    t.string "item_type"
    t.bigint "item_id"
    t.index ["inventoryable_type", "inventoryable_id"], name: "idx_on_inventoryable_type_inventoryable_id_b03b06a8f2"
    t.index ["item_type", "item_id"], name: "index_inventory_transactions_on_item_type_and_item_id"
    t.index ["user_id"], name: "index_inventory_transactions_on_user_id"
  end

  create_table "materials", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.string "category"
    t.string "subcategory"
    t.decimal "current_cost", precision: 10, scale: 2
    t.string "unit_of_measure", default: "gram"
    t.decimal "current_stock", precision: 10, scale: 4, default: "0.0"
    t.decimal "minimum_stock", precision: 10, scale: 4, default: "0.0"
    t.string "supplier"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_materials_on_category"
    t.index ["code"], name: "index_materials_on_code", unique: true
    t.index ["is_active"], name: "index_materials_on_is_active"
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
    t.integer "minimum_stock_level"
    t.string "supplier"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "reserved_stock", default: "0.0"
    t.datetime "last_restocked_at"
    t.decimal "reorder_point"
    t.decimal "optimal_stock_level"
    t.index ["minimum_stock_level"], name: "index_products_on_minimum_stock_level"
    t.index ["stock_quantity", "minimum_stock_level"], name: "index_products_on_stock_levels"
    t.index ["stock_quantity"], name: "index_products_on_stock_quantity"
  end

  create_table "sales_order_items", force: :cascade do |t|
    t.bigint "sales_order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.decimal "unit_price"
    t.decimal "total_price"
    t.text "specifications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sales_order_items_on_product_id"
    t.index ["sales_order_id"], name: "index_sales_order_items_on_sales_order_id"
  end

  create_table "sales_orders", force: :cascade do |t|
    t.string "order_id"
    t.bigint "customer_id", null: false
    t.bigint "employee_id"
    t.datetime "order_date"
    t.datetime "delivery_date"
    t.decimal "quotation_amount"
    t.decimal "total_amount"
    t.decimal "deposit_amount"
    t.decimal "remaining_amount"
    t.integer "order_status", default: 0
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.datetime "cancelled_at"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "shipping_amount", precision: 10, scale: 2, default: "0.0"
    t.bigint "user_id", null: false
    t.index ["completed_at"], name: "index_sales_orders_on_completed_at"
    t.index ["customer_id"], name: "index_sales_orders_on_customer_id"
    t.index ["employee_id"], name: "index_sales_orders_on_employee_id"
    t.index ["user_id"], name: "index_sales_orders_on_user_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bill_of_materials", "products"
  add_foreign_key "bom_items", "bill_of_materials"
  add_foreign_key "bom_items", "materials"
  add_foreign_key "design_images", "design_requests"
  add_foreign_key "design_requests", "customers"
  add_foreign_key "design_requests", "employees", column: "assigned_designer_id"
  add_foreign_key "design_requests", "sales_orders"
  add_foreign_key "employees", "employees", column: "supervisor_id"
  add_foreign_key "inventory_adjustments", "users"
  add_foreign_key "inventory_transactions", "users"
  add_foreign_key "sales_order_items", "products"
  add_foreign_key "sales_order_items", "sales_orders"
  add_foreign_key "sales_orders", "customers"
  add_foreign_key "sales_orders", "employees"
  add_foreign_key "sales_orders", "users"
  add_foreign_key "users", "employees"
end
