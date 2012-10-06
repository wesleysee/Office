class AddIncludeSaturdaySalary < ActiveRecord::Migration
  def change
    add_column :employees, :include_saturday_salary, :boolean
  end
end
