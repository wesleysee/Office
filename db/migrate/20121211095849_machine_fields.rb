class MachineFields < ActiveRecord::Migration
  def change
    add_column :ta_record_infos, :imported, :boolean
    add_index :ta_record_infos, [:Per_ID, :imported, :Date_Time]
  end
end
