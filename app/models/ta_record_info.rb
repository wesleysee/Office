class TaRecordInfo < ActiveRecord::Base
  attr_accessor :date
  attr_accessor :time

  columns_hash["date"] = ActiveRecord::ConnectionAdapters::Column.new("date", nil, "date")
  columns_hash["time"] = ActiveRecord::ConnectionAdapters::Column.new("time", nil, "time")

  self.primary_key = "ID"

  belongs_to :employee, :foreign_key => "Per_Code"

  before_save :before_save

  after_initialize :after_initialize

  def before_save
    self.Date_Time = self.date.to_s + " " + self.time.strftime("%H:%M:%S")
  end

  def after_initialize
    if not self.Date_Time.nil?
      self.date = Date.parse(self.Date_Time)
      self.time = Time.parse(self.Date_Time)
    elsif self.time.nil?
      self.time = Time.now.change(hour: 0, minute: 0)
    end
  end

  def self.search(search)
    if search
      includes(:employee).where('employees.name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

  def employee_name
    employee.try(:name)
  end

  def employee_name=(name)
    self.employee = Employee.find_by_name(name) if name.present?
  end
end
