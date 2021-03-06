class CustomerDelivery < ActiveRecord::Base
  belongs_to :customer
  belongs_to :trucking

  accepts_nested_attributes_for :trucking, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true

  validates_uniqueness_of :trucking_id, scope: :customer_id
  validates :delivery_method, :presence => true
  validates_presence_of :trucking, :if => :requires_trucking?

  before_save :check_delivery_method

  def check_delivery_method
    self.trucking_id = nil if not requires_trucking?
  end

  def requires_trucking?
    self.delivery_method == :trucking
  end
end
