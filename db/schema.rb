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

ActiveRecord::Schema.define(version: 20170201052315) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "buildings", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "draws", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "status",          default: 0, null: false
    t.date     "intent_deadline"
  end

  create_table "draws_suites", id: false, force: :cascade do |t|
    t.integer "draw_id",  null: false
    t.integer "suite_id", null: false
    t.index ["draw_id"], name: "index_draws_suites_on_draw_id", using: :btree
    t.index ["suite_id"], name: "index_draws_suites_on_suite_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "size",              default: 1, null: false
    t.integer  "status",            default: 0, null: false
    t.integer  "leader_id",                     null: false
    t.integer  "draw_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "memberships_count", default: 0, null: false
    t.index ["draw_id"], name: "index_groups_on_draw_id", using: :btree
    t.index ["leader_id"], name: "index_groups_on_leader_id", using: :btree
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "status",     default: 0, null: false
    t.index ["group_id"], name: "index_memberships_on_group_id", using: :btree
    t.index ["user_id"], name: "index_memberships_on_user_id", using: :btree
  end

  create_table "rooms", force: :cascade do |t|
    t.integer  "suite_id"
    t.string   "number",                 null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "beds",       default: 0, null: false
    t.index ["suite_id"], name: "index_rooms_on_suite_id", using: :btree
  end

  create_table "suites", force: :cascade do |t|
    t.integer  "building_id"
    t.string   "number",                  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "size",        default: 0, null: false
    t.index ["building_id"], name: "index_suites_on_building_id", using: :btree
  end

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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "role",                   default: 0,  null: false
    t.string   "first_name",                          null: false
    t.string   "last_name",                           null: false
    t.integer  "draw_id"
    t.integer  "intent",                 default: 0,  null: false
    t.integer  "gender",                 default: 0,  null: false
    t.string   "username"
    t.integer  "class_year"
    t.string   "college"
    t.index ["draw_id"], name: "index_users_on_draw_id", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

end
