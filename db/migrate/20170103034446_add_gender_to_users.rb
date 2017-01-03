class AddGenderToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :gender, :integer, null: false, default: 0
  end
end
