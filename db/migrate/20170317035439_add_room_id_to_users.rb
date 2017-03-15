class AddRoomIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :room, foreign_key: true
  end
end
