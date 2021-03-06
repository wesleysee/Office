require 'net/http'

class TimeRecord < ActiveRecord::Base
  belongs_to :employee

  validates :employee_id, presence: true
  validates :date, presence: true
  validates_uniqueness_of :date, :scope => :employee_id
  validate :time_end_is_less_than_time_start

  default_scope order: 'time_records.date DESC'

  before_save :do_calculations
  after_save  :send_notifications

  def incomplete?
    self.am_start.nil? or self.am_end.nil? or self.pm_start.nil? or self.pm_end.nil?
  end

  def do_calculations
    check_lunch_hours
    calculate_hours
    calculate_pay
  end

  def check_lunch_hours
    self.am_end = Date.new(2000, 1, 1) + 12.hour + 0.minute if self.am_end.nil? and not self.am_start.nil? and not self.pm_end.nil?
    self.pm_start = self.am_end + self.employee.lunch_minutes.minute if self.pm_start.nil? and not self.am_end.nil? and not self.pm_end.nil?
  end

  def calculate_hours
    total_seconds = 0
    total_seconds += (self.am_end - self.am_start) unless self.am_start.nil? or self.am_end.nil?
    total_seconds += (self.pm_end - self.pm_start) unless self.pm_start.nil? or self.pm_end.nil?
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
    self.allowance_pay = employee.allowance * self.regular_time_in_seconds / (employee.working_hours * 3600)
    self.overtime_pay = (self.salary / employee.working_hours) * self.overtime_in_seconds / 3600
    holiday_multiplier = 0
    if not self.date.nil?
      holiday = Holiday.find_by_date self.date
      holiday_multiplier = holiday.multiplier if not holiday.nil?
    end
    self.holiday_pay = holiday_multiplier * (self.regular_service_pay + self.overtime_pay * employee.overtime_multiplier)
    self.adjusted_holiday_pay = holiday_multiplier * self.regular_service_pay
    self.holiday_pay = self.salary if self.adjusted_holiday_pay < self.salary and holiday_multiplier == 1
    self.adjusted_holiday_pay = self.salary if self.adjusted_holiday_pay < self.salary and holiday_multiplier == 1
    self.regular_service_pay *= 1.5 if self.date.sunday?
    self.overtime_pay = self.date.sunday? ? self.overtime_pay * 1.5 : self.overtime_pay * employee.overtime_multiplier
    if self.employee.overtime_multiplier == 1
      self.regular_service_pay += self.overtime_pay
      self.overtime_pay = 0
      self.regular_time_in_seconds += self.overtime_in_seconds
      self.overtime_in_seconds = 0
    end
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
    default_date = Date.new(2000, 1, 1)
    self.am_start = default_date + 8.hour + 30.minute if self.am_start.nil?
    self.am_end = default_date + 12.hour + 0.minute if self.am_end.nil?
    self.pm_start = default_date + 12.hour + 30.minute if self.pm_start.nil?
    self.pm_end = default_date + 18.hour + 30.minute if self.pm_end.nil?
    self.salary = self.employee.salary unless not self.salary.nil? or self.employee.nil?
    self.date = Date.today.monday? ? Date.today - 2.days : Date.today - 1.day if self.date.nil?
    self.deductions = 0 if self.deductions.nil?
  end

  def send_notifications
    if not employee.salaried
      send_to_bodega_app(
        create_bodega_app_payload(
          self.regular_time_in_seconds.to_f / (employee.working_hours * 60 * 60),
          'regular'
        )
      )
      send_to_bodega_app(
        create_bodega_app_payload(
          self.overtime_in_seconds.to_f / (60 * 60.0),
          'overtime'
        )
      )
    end
  end

  private

    def display_time_in_hours(time)
      Time.at(time).utc.strftime("%H:%M") unless time.nil?
    end

    def time_end_is_less_than_time_start
      errors.add(:am_end, "should be later than AM start") if not self.am_start.nil? and not self.am_end.nil? and self.am_start > self.am_end
      errors.add(:pm_end, "should be later than PM start") if not self.pm_start.nil? and not self.pm_end.nil? and self.pm_start > self.pm_end
    end

    def create_bodega_app_payload(amount, attendance_type)
      return { :name => employee.name,
        :attendance => {
          :amount => amount,
          :applies_on => self.date.strftime('%F'),
          :attendance_type => attendance_type
        }
      }
    end

    def send_to_bodega_app(payload)
      url = 'https://immense-ridge-61534.herokuapp.com/attendances'
      uri = URI(url)
      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      req.body = payload.to_json
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.request(req)
    end

end
