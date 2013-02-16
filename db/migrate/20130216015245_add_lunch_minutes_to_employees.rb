class AddLunchMinutesToEmployees < ActiveRecord::Migration
  def change
    change_table :employees do |t|
      t.column :lunch_minutes, :integer
    end
  end
end
