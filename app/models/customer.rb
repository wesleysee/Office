class Customer < ActiveRecord::Base
  has_many :customer_deliveries
  has_many :truckings, :through => :customer_deliveries
  has_many :customer_products

  accepts_nested_attributes_for :customer_deliveries, :reject_if => lambda { |a| a[:delivery_method].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :customer_products, :reject_if => lambda { |a| a[:product_name].blank? }, :allow_destroy => true

  validates :name, presence: true

  def self.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

end
