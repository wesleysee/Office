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

ActiveRecord::Schema.define(:version => 20140614030823) do

  create_table "customer_deliveries", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "trucking_id"
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
    t.enum     "delivery_method", :limit => [:pickup, :deliver, :trucking], :default => :pickup
    t.string   "notes"
  end

  create_table "customer_products", :force => true do |t|
    t.integer  "customer_id"
    t.string   "product_name"
    t.decimal  "price",        :precision => 10, :scale => 2
    t.string   "unit"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "deduction_types", :force => true do |t|
    t.string "name"
  end

  create_table "deductions", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "year"
    t.integer  "week"
    t.decimal  "amount",            :precision => 10, :scale => 2
    t.integer  "deduction_type_id"
    t.integer  "deduction_year"
    t.integer  "deduction_month"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

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
    t.boolean  "generate_time_record"
    t.integer  "lunch_minutes"
  end

  create_table "holidays", :force => true do |t|
    t.date    "date"
    t.string  "name"
    t.decimal "multiplier", :precision => 10, :scale => 2
  end

  add_index "holidays", ["date"], :name => "index_holidays_on_date", :unique => true

  create_table "rsvps", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.integer  "guests"
    t.boolean  "attending"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "notes"
    t.text     "questions"
  end

  create_table "ta_record_infos", :primary_key => "ID", :force => true do |t|
    t.integer "Mach_Name",   :limit => 2
    t.integer "Per_ID"
    t.integer "Per_Code"
    t.integer "Per_Finger",  :limit => 1
    t.string  "Date_Time",   :limit => 20
    t.integer "R_State",     :limit => 1
    t.integer "In_Out",      :limit => 1
    t.integer "R_Qian",      :limit => 1
    t.integer "R_Qian_Type", :limit => 1
    t.integer "Qian_Op"
    t.integer "TA_OR_AT",    :limit => 1
    t.integer "FP_Mode"
    t.boolean "imported",                  :default => false, :null => false
  end

  add_index "ta_record_infos", ["Per_ID", "Date_Time"], :name => "index_ta_record_infos_on_Per_ID_and_imported_and_Date_Time"

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

  create_table "truckings", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "truckings", ["name"], :name => "truckings_name_unique", :unique => true

end
