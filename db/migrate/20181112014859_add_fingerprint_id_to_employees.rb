class AddFingerprintIdToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :fingerprint_id, :integer
    add_index :employees, :fingerprint_id
  end
end
