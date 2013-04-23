class TaRecordInfo < ActiveRecord::Base
  self.primary_key = "ID"

  belongs_to :employee, :foreign_key => "Per_Code"

  def self.search(search)
    if search
      includes(:employee).where('employees.name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
