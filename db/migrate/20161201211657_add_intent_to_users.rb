class AddIntentToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :intent, :integer, null: false, default: 0
  end
end
