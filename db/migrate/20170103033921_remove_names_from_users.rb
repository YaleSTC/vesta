class RemoveNamesFromUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.remove :middle_name, :preferred_name
    end
  end
end
