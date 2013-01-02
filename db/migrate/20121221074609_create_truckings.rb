class CreateTruckings < ActiveRecord::Migration
  def change
    create_table :truckings do |t|
      t.string :name
      t.string :address
      t.string :phone

      t.timestamps
    end
  end
end
