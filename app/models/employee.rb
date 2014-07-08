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
    self.allowance ||= 20 if self.has_attribute? :allowance
    self.working_hours ||= 8 if self.has_attribute? :working_hours
    self.overtime_multiplier ||= 1.25 if self.has_attribute? :overtime_multiplier
  end

  def init_kimson
    self.company = "Kimson"
    self.working_hours = 9
    self.salaried = false
    self.salary = 250
    self.overtime_multiplier = 0
    self.allowance = 0
    self.include_saturday_salary = false
    self.generate_time_record = true
    self.lunch_minutes = 30
  end

  def self.salaried_employees
    where("salaried = true")
  end

  def self.active_employees
    where(:status => "active")
  end

end
