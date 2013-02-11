class AddDateToTaRecordInfo < ActiveRecord::Migration
  def change
    change_table :ta_record_infos do |t|
      t.column :created_at, :datetime
    end
  end
end
