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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121008071031) do

  create_table "employees", :force => true do |t|
    t.string   "name"
    t.string   "company"
    t.enum     "status",                  :limit => [:active, :deleted],                                :default => :active
    t.integer  "working_hours"
    t.boolean  "salaried"
    t.decimal  "salary",                                                 :precision => 10, :scale => 2
    t.decimal  "overtime_multiplier",                                    :precision => 4,  :scale => 2
    t.decimal  "allowance",                                              :precision => 4,  :scale => 2
    t.datetime "created_at",                                                                                                 :null => false
    t.datetime "updated_at",                                                                                                 :null => false
    t.boolean  "include_saturday_salary"
  end

  create_table "holidays", :force => true do |t|
    t.date    "date"
    t.string  "name"
    t.integer "multiplier"
  end

  create_table "time_records", :force => true do |t|
    t.integer  "employee_id"
    t.date     "date"
    t.time     "am_start"
    t.time     "am_end"
    t.time     "pm_start"
    t.time     "pm_end"
    t.integer  "regular_time_in_seconds"
    t.integer  "overtime_in_seconds"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.decimal  "salary",                  :precision => 10, :scale => 2
    t.decimal  "regular_service_pay",     :precision => 10, :scale => 2
    t.decimal  "overtime_pay",            :precision => 10, :scale => 2
    t.decimal  "allowance_pay",           :precision => 10, :scale => 2
    t.decimal  "holiday_pay",             :precision => 10, :scale => 2
    t.decimal  "adjusted_holiday_pay",    :precision => 10, :scale => 2
    t.decimal  "deductions",              :precision => 10, :scale => 2
  end

  add_index "time_records", ["employee_id", "date"], :name => "index_time_records_on_employee_id_and_date"

end
