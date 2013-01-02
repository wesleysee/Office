class DropLocationFromCustomerDelivery < ActiveRecord::Migration
  def change
    remove_column :customer_delivery, :location
    rename_table :customer_delivery, :customer_deliveries
  end
end
