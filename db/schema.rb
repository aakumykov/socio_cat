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

ActiveRecord::Schema.define(version: 20160303094353) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "kind",               default: "draft"
    t.string   "title"
    t.text     "text"
    t.text     "description"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "audio_file_name"
    t.string   "audio_content_type"
    t.integer  "audio_file_size"
    t.datetime "audio_updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.datetime "media_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "matter_id"
  end

  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "cc_relations", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cc_relations", ["card_id"], name: "index_cc_relations_on_card_id", using: :btree
  add_index "cc_relations", ["category_id", "card_id"], name: "index_cc_relations_on_category_id_and_card_id", unique: true, using: :btree
  add_index "cc_relations", ["category_id"], name: "index_cc_relations_on_category_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "matters", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "matters", ["name"], name: "index_matters_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.text     "name"
    t.text     "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                default: false
    t.boolean  "in_reset",             default: false
    t.string   "reset_code"
    t.datetime "reset_date"
    t.boolean  "in_pass_reset",        default: false
    t.datetime "new_pass_expire_time"
    t.boolean  "activated",            default: false
    t.string   "activation_code"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
