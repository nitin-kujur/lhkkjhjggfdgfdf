# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160907153328) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer  "distributor_id"
    t.string   "address1"
    t.string   "city"
    t.string   "province"
    t.string   "phone"
    t.string   "zip"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "country"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "addresses", ["distributor_id"], name: "index_addresses_on_distributor_id", using: :btree

  create_table "distributors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.boolean  "verified_email"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "shopify_id"
  end

  create_table "grid_infos", force: :cascade do |t|
    t.string   "location_ids"
    t.string   "string"
    t.string   "product_ids"
    t.string   "identifier"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "product_quantities", force: :cascade do |t|
    t.integer  "first_quantity"
    t.integer  "last_quantity"
    t.float    "price"
    t.integer  "product_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "product_quantities", ["product_id"], name: "index_product_quantities_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "shopify_product_id"
    t.integer  "min_quantity"
    t.integer  "shop_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string   "shopify_domain", null: false
    t.string   "shopify_token",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shops", ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "shop_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "addresses", "distributors"
  add_foreign_key "product_quantities", "products"
end
