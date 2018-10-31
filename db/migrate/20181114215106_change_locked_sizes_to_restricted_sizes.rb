class ChangeLockedSizesToRestrictedSizes < ActiveRecord::Migration[5.1]
  def change
  	rename_column :draws, :locked_sizes, :restricted_sizes
  end
end
