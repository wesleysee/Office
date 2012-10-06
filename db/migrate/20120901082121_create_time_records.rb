class CreateTimeRecords < ActiveRecord::Migration
  def change
    create_table :time_records do |t|
      t.integer :employee_id
      t.date :date
      t.time :am_start
      t.time :am_end
      t.time :pm_start
      t.time :pm_end
      t.integer :regular_time_in_seconds
      t.integer :overtime_in_seconds

      t.timestamps
    end
    add_index :time_records, [:employee_id, :date]
  end
end
