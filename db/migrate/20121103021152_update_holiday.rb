class UpdateHoliday < ActiveRecord::Migration
  def change
    change_table :holidays do |t|
      t.change :multiplier, :decimal, :precision => 10, :scale => 2
    end
  end
end
