class CreateCustomerTruckings < ActiveRecord::Migration
  def change
    create_table :customer_truckings do |t|
      t.integer :customer_id
      t.integer :trucking_id

      t.timestamps
    end
  end
end
