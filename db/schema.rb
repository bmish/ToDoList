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

ActiveRecord::Schema.define(version: 20140927034617) do

  create_table "categories", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["title"], name: "index_categories_on_title", unique: true

  create_table "fields", force: true do |t|
    t.string   "name",                                null: false
    t.string   "titleForDB"
    t.string   "titleForList"
    t.string   "titleForCSV"
    t.string   "titleForForm"
    t.string   "dataType"
    t.integer  "orderDisplay"
    t.integer  "orderSort"
    t.boolean  "displayInSimpleList", default: false, null: false
    t.boolean  "displayInFullList",   default: false, null: false
    t.boolean  "isFormField",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fields", ["name"], name: "index_fields_on_name", unique: true
  add_index "fields", ["orderDisplay"], name: "index_fields_on_orderDisplay", unique: true
  add_index "fields", ["orderSort"], name: "index_fields_on_orderSort", unique: true

  create_table "lists", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: true do |t|
    t.string   "title"
    t.integer  "priority"
    t.text     "notes"
    t.boolean  "done",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.integer  "list_id"
    t.boolean  "deleted",     default: false
    t.boolean  "blocked",     default: false
    t.date     "due"
    t.string   "location"
    t.integer  "frequency",   default: 1
    t.string   "dependee"
    t.date     "start"
    t.boolean  "underway"
  end

  add_index "tasks", ["category_id"], name: "index_tasks_on_category_id"
  add_index "tasks", ["list_id"], name: "index_tasks_on_list_id"
  add_index "tasks", ["title", "list_id"], name: "index_tasks_on_title_and_list_id", unique: true

end
