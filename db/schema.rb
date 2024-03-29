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

ActiveRecord::Schema.define(version: 20140525131635) do

  create_table "club_networks", force: true do |t|
    t.integer "club_id"
    t.integer "network_id"
    t.boolean "verified",   default: false
  end

  create_table "clubs", force: true do |t|
    t.string   "name",                default: "",    null: false
    t.text     "description"
    t.string   "website"
    t.integer  "uni_registration_id", default: -1,    null: false
    t.boolean  "confirmed",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clubs", ["uni_registration_id"], name: "index_clubs_on_uni_registration_id", unique: true

  create_table "comments", force: true do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.string  "message"
  end

  create_table "events", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
    t.datetime "start_time"
    t.integer  "club_id"
    t.date     "visibledate"
    t.string   "location"
    t.string   "imagea"
    t.string   "imageb"
    t.string   "imagec"
  end

  create_table "memberships", force: true do |t|
    t.integer  "club_id"
    t.integer  "user_id"
    t.integer  "rank",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      default: ""
  end

  create_table "messages", force: true do |t|
    t.integer  "user_id"
    t.string   "message"
    t.boolean  "read",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", force: true do |t|
    t.string "name"
  end

  create_table "ticket_reservations", force: true do |t|
    t.integer  "user_id"
    t.integer  "ticket_id"
    t.integer  "event_id"
    t.integer  "m_amount"
    t.integer  "n_amount"
    t.integer  "s_amount"
    t.boolean  "pickedup",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tickets", force: true do |t|
    t.integer "event_id"
    t.string  "tname"
    t.decimal "mprice",    precision: 8, scale: 2
    t.decimal "nprice",    precision: 8, scale: 2
    t.decimal "sprice",    precision: 8, scale: 2
    t.integer "total"
    t.integer "remaining"
    t.string  "pickup"
    t.date    "opendate"
    t.date    "closedate"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",             default: "",    null: false
    t.string   "last_name",              default: "",    null: false
    t.integer  "phone"
    t.boolean  "admin",                  default: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
