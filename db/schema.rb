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

ActiveRecord::Schema.define(version: 20170205091652) do

  create_table "applies", force: :cascade do |t|
    t.text     "resume"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "user_id"
    t.integer  "job_id"
    t.text     "cover_letter"
    t.text     "job_objective"
    t.text     "synopsis"
    t.text     "education"
    t.text     "experience"
    t.text     "skills"
    t.integer  "post_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "description"
    t.string   "link"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "logo_image_url_for_script"
    t.boolean  "set_image",                 default: false
  end

  create_table "jobs", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.text     "qualification"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "company_id"
    t.string   "source"
    t.string   "location"
    t.string   "tags_for_script"
    t.string   "country_code"
    t.string   "continent"
  end

  create_table "location_relationships", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "location_relationships", ["job_id"], name: "index_location_relationships_on_job_id"
  add_index "location_relationships", ["location_id"], name: "index_location_relationships_on_location_id"

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "company_id"
    t.integer  "publisher_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "location"
    t.text     "qualification"
  end

  add_index "posts", ["company_id"], name: "index_posts_on_company_id"
  add_index "posts", ["publisher_id"], name: "index_posts_on_publisher_id"

  create_table "taggings", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "taggings", ["job_id"], name: "index_taggings_on_job_id"
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id"

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "mobile_number"
    t.string   "city"
    t.string   "country"
    t.string   "postal_code"
    t.text     "synopsis"
    t.text     "year_in_industry"
    t.text     "education"
    t.text     "experience"
    t.text     "skills"
    t.string   "resume_file_name"
    t.string   "resume_content_type"
    t.integer  "resume_file_size"
    t.datetime "resume_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "watchlists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.integer  "job_id"
  end

  add_index "watchlists", ["job_id"], name: "index_watchlists_on_job_id"
  add_index "watchlists", ["user_id"], name: "index_watchlists_on_user_id"

end
