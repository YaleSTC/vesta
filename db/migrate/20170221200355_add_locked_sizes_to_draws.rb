class AddLockedSizesToDraws < ActiveRecord::Migration[5.0]
  def change
    add_column :draws, :locked_sizes, :integer, array: true, default: [], null: false
  end
end
