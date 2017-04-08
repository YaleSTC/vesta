class AddOriginalSuiteToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :original_suite, :string, default: '', null: false
  end
end
