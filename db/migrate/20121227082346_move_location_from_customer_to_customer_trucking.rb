class MoveLocationFromCustomerToCustomerTrucking < ActiveRecord::Migration
  def change
    remove_column :customers, :location
    add_column :customer_truckings, :location, :string
  end
end
