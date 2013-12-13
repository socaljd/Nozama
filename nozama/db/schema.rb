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

ActiveRecord::Schema.define(version: 20131107072539) do

  create_table "inventories", force: true do |t|
    t.integer  "user_id"
    t.integer  "batch_id"
    t.date     "received_date"
    t.string   "fnsku"
    t.string   "sku"
    t.text     "product_name"
    t.integer  "quantity"
    t.string   "fba_shipment_id"
    t.string   "fulfillment_center_id"
    t.integer  "quantity_remaining"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventories", ["user_id", "received_date"], name: "index_inventories_on_user_id_and_received_date", using: :btree

  create_table "sales", force: true do |t|
    t.integer  "user_id"
    t.integer  "batch_id"
    t.integer  "item_id"
    t.integer  "days_in_inventory"
    t.date     "shipment_date"
    t.string   "sku"
    t.string   "fnsku"
    t.string   "asin"
    t.string   "fulfillment_center_id"
    t.integer  "quantity"
    t.string   "amazon_order_id"
    t.string   "currency"
    t.decimal  "item_price_per_unit",   precision: 10, scale: 2
    t.decimal  "shipping_price",        precision: 10, scale: 2
    t.decimal  "gift_wrap_price",       precision: 10, scale: 2
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_postal_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales", ["user_id", "shipment_date"], name: "index_sales_on_user_id_and_shipment_date", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
