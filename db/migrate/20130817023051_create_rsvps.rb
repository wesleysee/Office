class CreateRsvps < ActiveRecord::Migration
  def change
    create_table :rsvps do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.integer :guests
      t.boolean :attending

      t.timestamps
    end
  end
end
