class RemoveCollegeFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :college
  end
end
