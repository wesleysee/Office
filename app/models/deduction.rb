class Deduction < ActiveRecord::Base
  belongs_to :employee
  belongs_to :deduction_type

  validates :employee_id, presence: true
  validates :amount, presence: true
  validates :deduction_type_id, presence: true
  validates :year, presence: true
  validates :week, presence: true
  validates :deduction_year, presence: true
  validates :deduction_month, presence: true

  def deduction_month_str
    self.deduction_month.to_s + "/" + self.deduction_year.to_s
  end
end
