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

ActiveRecord::Schema.define(version: 20150522210651) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admission_items", force: :cascade do |t|
    t.integer "admission_id"
    t.string  "name"
    t.float   "value"
    t.string  "change"
    t.string  "ownership_form"
    t.string  "ownership_part"
    t.string  "category"
    t.string  "acquisition_date"
    t.string  "acquisition_reason"
  end

  add_index "admission_items", ["acquisition_date"], name: "index_admission_items_on_acquisition_date", using: :btree
  add_index "admission_items", ["acquisition_reason"], name: "index_admission_items_on_acquisition_reason", using: :btree
  add_index "admission_items", ["admission_id"], name: "index_admission_items_on_admission_id", using: :btree
  add_index "admission_items", ["category"], name: "index_admission_items_on_category", using: :btree
  add_index "admission_items", ["change"], name: "index_admission_items_on_change", using: :btree
  add_index "admission_items", ["name"], name: "index_admission_items_on_name", using: :btree
  add_index "admission_items", ["ownership_form"], name: "index_admission_items_on_ownership_form", using: :btree
  add_index "admission_items", ["ownership_part"], name: "index_admission_items_on_ownership_part", using: :btree
  add_index "admission_items", ["value"], name: "index_admission_items_on_value", using: :btree

  create_table "admissions", force: :cascade do |t|
    t.integer "judge_id"
    t.integer "year"
    t.boolean "proclamation1"
    t.boolean "proclamation2"
    t.boolean "proclamation3"
    t.boolean "proclamation4"
    t.boolean "proclamation5"
    t.boolean "proclamation6"
    t.string  "url"
  end

  add_index "admissions", ["judge_id"], name: "index_admissions_on_judge_id", using: :btree
  add_index "admissions", ["proclamation1"], name: "index_admissions_on_proclamation1", using: :btree
  add_index "admissions", ["proclamation2"], name: "index_admissions_on_proclamation2", using: :btree
  add_index "admissions", ["proclamation3"], name: "index_admissions_on_proclamation3", using: :btree
  add_index "admissions", ["proclamation4"], name: "index_admissions_on_proclamation4", using: :btree
  add_index "admissions", ["proclamation5"], name: "index_admissions_on_proclamation5", using: :btree
  add_index "admissions", ["proclamation6"], name: "index_admissions_on_proclamation6", using: :btree
  add_index "admissions", ["year"], name: "index_admissions_on_year", using: :btree

  create_table "close_persons", force: :cascade do |t|
    t.integer "admission_id"
    t.string  "institution"
    t.string  "function"
    t.string  "name"
    t.string  "title_front"
    t.string  "title_back"
  end

  add_index "close_persons", ["admission_id"], name: "index_close_persons_on_admission_id", using: :btree
  add_index "close_persons", ["function"], name: "index_close_persons_on_function", using: :btree
  add_index "close_persons", ["institution"], name: "index_close_persons_on_institution", using: :btree
  add_index "close_persons", ["name"], name: "index_close_persons_on_name", using: :btree

  create_table "judges", force: :cascade do |t|
    t.string "name"
  end

  add_index "judges", ["name"], name: "index_judges_on_name", using: :btree

end
