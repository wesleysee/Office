class Trucking < ActiveRecord::Base
  has_many :customer_deliveries
  has_many :customers, :through => :customer_deliveries

  validates :name, presence: true
  validates_uniqueness_of :name
end
