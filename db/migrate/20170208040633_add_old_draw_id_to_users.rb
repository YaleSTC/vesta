class AddOldDrawIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :old_draw_id, :integer
  end
end
