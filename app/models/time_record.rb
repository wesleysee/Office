class TimeRecord < ActiveRecord::Base
  belongs_to :employee

  validates :employee_id, presence: true
  validates :date, presence: true
  validates_uniqueness_of :date, :scope => :employee_id
  validate :time_end_is_less_than_time_start

  default_scope order: 'time_records.date DESC'

  before_save :do_calculations

  def do_calculations
    calculate_hours
    calculate_pay
  end

  def calculate_hours
    total_seconds = 0
    total_seconds += (self.am_end - self.am_start) unless self.am_start.nil?
    total_seconds += (self.pm_end - self.pm_start) unless self.pm_start.nil?
    if total_seconds > employee.working_hours * 60 * 60
      self.regular_time_in_seconds = employee.working_hours * 60 * 60
      self.overtime_in_seconds = total_seconds - employee.working_hours * 60 * 60
    else
      self.regular_time_in_seconds = total_seconds
      self.overtime_in_seconds = 0
    end
  end

  def calculate_pay
    if self.salary.nil?
      self.salary = employee.salary
    end
    self.regular_service_pay = self.salary * self.regular_time_in_seconds / (employee.working_hours * 3600)
    self.overtime_pay = (self.salary / employee.working_hours) * employee.overtime_multiplier * self.overtime_in_seconds / 3600
    if self.date.sunday?
      self.regular_service_pay *= 1.5
      self.overtime_pay *= 1.5
    end
    self.allowance_pay = employee.allowance * self.regular_time_in_seconds / (employee.working_hours * 3600)
    holiday_multiplier = 0
    self.holiday_pay = holiday_multiplier * (self.regular_service_pay + self.overtime_pay)
    self.adjusted_holiday_pay = holiday_multiplier * self.regular_service_pay
  end

  def regular_time
    display_time_in_hours(self.regular_time_in_seconds)
  end

  def overtime
    display_time_in_hours(self.overtime_in_seconds)
  end

  def am_start_str
    display_time_in_hours(self.am_start)
  end

  def am_end_str
    display_time_in_hours(self.am_end)
  end

  def pm_start_str
    display_time_in_hours(self.pm_start)
  end

  def pm_end_str
    display_time_in_hours(self.pm_end)
  end

  def total_pay
    self.regular_service_pay + self.overtime_pay + self.allowance_pay
  end

  def init
    self.am_start = Date.today + 8.hour + 30.minute
    self.am_end = Date.today + 12.hour + 0.minute
    self.pm_start = Date.today + 12.hour + 30.minute
    self.pm_end = Date.today + 18.hour + 0.minute
    self.salary = self.employee.salary unless self.employee.nil?
    self.date = Date.today.monday? ? Date.today - 2.days : Date.today - 1.day
    self.deductions = 0
  end

  private

    def display_time_in_hours(time)
      Time.at(time).utc.strftime("%H:%M")
    end

    def time_end_is_less_than_time_start
      errors.add(:am_end, "should be later than AM start") if not self.am_start.nil? and not self.am_end.nil? and self.am_start > self.am_end
      errors.add(:pm_end, "should be later than PM start") if not self.pm_start.nil? and not self.pm_end.nil? and self.pm_start > self.pm_end
    end

end
