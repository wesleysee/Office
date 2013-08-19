class AddQuestionsToRsvp < ActiveRecord::Migration
  def change
    add_column :rsvps, :questions, :string
  end
end
