class CreateCustomerProducts < ActiveRecord::Migration
  def change
    create_table :customer_products do |t|
      t.integer :customer_id
      t.string :product_name
      t.decimal :price, :precision => 10, :scale => 2
      t.string :unit

      t.timestamps
    end
  end
end
