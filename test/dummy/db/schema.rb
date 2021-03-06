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

ActiveRecord::Schema.define(version: 20150910222715) do

  create_table "dynamic_forms_engine_dynamic_form_entries", force: true do |t|
    t.integer  "dynamic_form_type_id"
    t.text     "properties"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "signature"
    t.boolean  "in_progress"
    t.string   "last_section_saved"
    t.string   "application_pdf"
  end

  create_table "dynamic_forms_engine_dynamic_form_fields", force: true do |t|
    t.integer  "dynamic_form_type_id"
    t.integer  "field_order"
    t.string   "name"
    t.string   "field_type"
    t.boolean  "required"
    t.text     "content_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "included_in_report"
    t.string   "field_width"
  end

  create_table "dynamic_forms_engine_dynamic_form_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "form_type"
    t.boolean  "is_public"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
