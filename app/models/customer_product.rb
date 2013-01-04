class CustomerProduct < ActiveRecord::Base
  belongs_to :customer

  validates_presence_of :customer_id
  validates_presence_of :product_name
  validates_presence_of :price
  validates_presence_of :unit

  validates_numericality_of :price, :greater_than_or_equal_to => 0.01
end
