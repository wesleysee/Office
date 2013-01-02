class CreateDeductionTypes < ActiveRecord::Migration
  def change
    create_table :deduction_types do |t|
      t.string :name
    end
  end
end
