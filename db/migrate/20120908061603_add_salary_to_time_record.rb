class AddSalaryToTimeRecord < ActiveRecord::Migration
  def change
    add_column :time_records, :salary, :decimal

    add_column :time_records, :regular_service_pay, :decimal

    add_column :time_records, :overtime_pay, :decimal

    add_column :time_records, :allowance_pay, :decimal

    add_column :time_records, :holiday_pay, :decimal

    add_column :time_records, :adjusted_holiday_pay, :decimal

    add_column :time_records, :deductions, :decimal

  end
end
