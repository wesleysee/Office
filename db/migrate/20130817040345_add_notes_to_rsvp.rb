class AddNotesToRsvp < ActiveRecord::Migration
  def change
    add_column :rsvps, :notes, :string
  end
end
