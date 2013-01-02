class AddDeliveryMethodToCustomer < ActiveRecord::Migration
  def change
    rename_table :customer_truckings, :customer_delivery
    change_table :customer_delivery do |t|
      t.column :delivery_method, :enum, :limit => [:pickup, :deliver, :trucking], :default => :pickup
      t.column :notes, :string
    end
  end
end
