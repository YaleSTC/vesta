class AddSidToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :student_id, :integer, null: true
    add_index :users, :student_id, unique: true
  end
end
