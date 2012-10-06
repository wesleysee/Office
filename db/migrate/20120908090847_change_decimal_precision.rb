class ChangeDecimalPrecision < ActiveRecord::Migration
  def change
    change_table :employees do |t|
      t.change :salary, :decimal, :precision => 10, :scale => 2
      t.change :overtime_multiplier, :decimal, :precision => 4, :scale => 2
      t.change :allowance, :decimal, :precision => 4, :scale => 2
    end

    change_table :time_records do |t|
      t.change :salary, :decimal, :precision => 10, :scale => 2
      t.change :regular_service_pay, :decimal, :precision => 10, :scale => 2
      t.change :overtime_pay, :decimal, :precision => 10, :scale => 2
      t.change :allowance_pay, :decimal, :precision => 10, :scale => 2
      t.change :holiday_pay, :decimal, :precision => 10, :scale => 2
      t.change :adjusted_holiday_pay, :decimal, :precision => 10, :scale => 2
    end
  end
end
