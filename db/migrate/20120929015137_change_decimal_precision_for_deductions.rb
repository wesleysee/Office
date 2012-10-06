class ChangeDecimalPrecisionForDeductions < ActiveRecord::Migration
  def change
    change_table :time_records do |t|
      t.change :deductions, :decimal, :precision => 10, :scale => 2
    end
  end
end
