class Employee < ActiveRecord::Base
  has_many :time_records, dependent: :destroy
  has_many :deductions, dependent: :destroy
  has_many :ta_record_infos, :foreign_key => "Per_Code", :conditions => {:imported => false},
           :order => "Date_Time asc", dependent: :destroy

  after_initialize :init

  validates :name, presence: true
  validates :company, presence: true
  validates :working_hours, presence: true
  validates_numericality_of :salary, :greater_than_or_equal_to => 0.01

  def init
    self.allowance ||= 20
    self.working_hours ||= 8
    self.overtime_multiplier ||= 1.25
  end

  def self.salaried_employees
    where("salaried = true")
  end

  def self.active_employees
    where(:status => "active")
  end

end
