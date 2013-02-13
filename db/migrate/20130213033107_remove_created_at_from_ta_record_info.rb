class RemoveCreatedAtFromTaRecordInfo < ActiveRecord::Migration
  def change
    remove_column :ta_record_infos, :created_at
  end
end
