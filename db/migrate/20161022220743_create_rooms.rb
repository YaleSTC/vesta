class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.belongs_to :suite, index: true
      t.string :number, null: false

      t.timestamps
    end
  end
end
