class AddGenerateTimeRecordToEmployee < ActiveRecord::Migration
  def change
    change_table :employees do |t|
      t.column :generate_time_record, :boolean
    end
  end
end
