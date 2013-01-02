class TaRecordInfo < ActiveRecord::Base
  self.primary_key = "ID"

  belongs_to :employee, :foreign_key => "Per_Code"
end
