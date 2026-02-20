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

ActiveRecord::Schema[8.0].define(version: 2025_12_26_052428) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "branches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "branch_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "branches_users", id: false, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "branch_id", null: false
    t.index ["branch_id"], name: "index_branches_users_on_branch_id"
    t.index ["user_id", "branch_id"], name: "index_branches_users_on_user_id_and_branch_id", unique: true
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id"
    t.uuid "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "product_id"], name: "index_categories_products_on_category_and_product", unique: true
    t.index ["category_id"], name: "index_categories_products_on_category_id"
    t.index ["product_id"], name: "index_categories_products_on_product_id"
  end

  create_table "inventory_item_branches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_item_id", null: false
    t.uuid "branch_id", null: false
    t.integer "stock", default: 0, null: false
    t.integer "safe_stock", default: 0, null: false
    t.integer "time_to_warning", default: 0, null: false
    t.integer "entry", default: 0, null: false
    t.integer "output", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_inventory_item_branches_on_branch_id"
    t.index ["inventory_item_id", "branch_id"], name: "index_inventory_item_branches_on_item_and_branch", unique: true
    t.index ["inventory_item_id"], name: "index_inventory_item_branches_on_inventory_item_id"
  end

  create_table "inventory_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "identifier"
    t.text "comment"
    t.string "unit"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((identifier)::text)", name: "index_inventory_items_on_lower_identifier", unique: true
    t.index ["identifier"], name: "index_inventory_items_on_identifier"
  end

  create_table "inventory_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.boolean "low_stock_alerts", default: true, null: false
    t.integer "low_stock_threshold", default: 10, null: false
    t.boolean "email_notifications", default: true, null: false
    t.string "branches_to_show", default: ["all"], null: false, array: true
    t.integer "default_items_per_page", default: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_inventory_preferences_on_user_id"
  end

  create_table "inventory_transaction_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_transaction_id", null: false
    t.uuid "inventory_item_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_item_id"], name: "index_inventory_transaction_items_on_inventory_item_id"
    t.index ["inventory_transaction_id", "inventory_item_id"], name: "index_inv_trans_items_on_trans_and_item", unique: true
    t.index ["inventory_transaction_id"], name: "index_inventory_transaction_items_on_inventory_transaction_id"
  end

  create_table "inventory_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "transaction_type"
    t.integer "transaction_subtype"
    t.text "note"
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "branch_id", null: false
    t.index ["branch_id"], name: "index_inventory_transactions_on_branch_id"
    t.index ["user_id"], name: "index_inventory_transactions_on_user_id"
  end

  create_table "item_components", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "owner_type", null: false
    t.uuid "owner_id", null: false
    t.string "component_type", null: false
    t.uuid "component_id", null: false
    t.decimal "quantity", precision: 12, scale: 4, default: "0.0", null: false
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_type", "component_id"], name: "index_item_components_on_component"
    t.index ["component_type", "component_id"], name: "index_item_components_on_component_type_and_component_id"
    t.index ["owner_type", "owner_id"], name: "index_item_components_on_owner"
    t.index ["owner_type", "owner_id"], name: "index_item_components_on_owner_type_and_owner_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "inventory_item_branches", "branches"
  add_foreign_key "inventory_item_branches", "inventory_items"
  add_foreign_key "inventory_preferences", "users"
  add_foreign_key "inventory_transaction_items", "inventory_items"
  add_foreign_key "inventory_transaction_items", "inventory_transactions"
  add_foreign_key "inventory_transactions", "branches"
  add_foreign_key "inventory_transactions", "users"
end
