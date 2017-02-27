class AddTransfersToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :transfers, :integer, null: false, default: 0
  end
end
