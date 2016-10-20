class AddBedsToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :beds, :integer, null: false, default: 0
  end
end
