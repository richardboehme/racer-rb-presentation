class CreateMeetings < ActiveRecord::Migration[8.1]
  def change
    create_table :meetings do |t|
      t.string :title
      t.date :held_on

      t.timestamps
    end
  end
end
