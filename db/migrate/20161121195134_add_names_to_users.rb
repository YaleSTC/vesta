class AddNamesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :first_name, :string, null: false
    add_column :users, :last_name, :string, null: false
    add_column :users, :preferred_name, :string
    add_column :users, :middle_name, :string
  end
end
