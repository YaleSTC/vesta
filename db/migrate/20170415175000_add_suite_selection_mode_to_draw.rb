class AddSuiteSelectionModeToDraw < ActiveRecord::Migration[5.0]
  def change
    add_column :draws, :suite_selection_mode, :integer, null: false, default: 0
  end
end
