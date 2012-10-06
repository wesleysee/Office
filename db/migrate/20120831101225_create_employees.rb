class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :name
      t.string :company
      t.column :status, :enum, :limit => [:active, :deleted], :default => :active
      t.integer :working_hours
      t.boolean :salaried
      t.decimal :salary
      t.decimal :overtime_multiplier
      t.decimal :allowance

      t.timestamps
    end
  end
end
