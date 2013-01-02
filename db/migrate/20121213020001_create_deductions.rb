class CreateDeductions < ActiveRecord::Migration
  def change
    create_table :deductions do |t|
      t.integer :employee_id
      t.integer :year
      t.integer :week
      t.decimal :amount, :precision => 10, :scale => 2
      t.integer :deduction_type_id
      t.integer :deduction_year
      t.integer :deduction_month

      t.timestamps
    end
  end
end
