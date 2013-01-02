class RenameCustomerTruckingToCustomerDelivery < ActiveRecord::Migration
  def up
    rename_table :customer_truckings, :customer_deliveries
  end

  def down
    rename_table :customer_deliveries, :customer_truckings
  end
end
