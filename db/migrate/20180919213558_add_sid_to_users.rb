class AddSidToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :student_sid, :integer, null: true
    add_index :users, :student_sid, unique: true
  end
end
