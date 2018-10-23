class AddRestrictClippingGroupSizeToDraws < ActiveRecord::Migration[5.1]
  def change
    add_column :draws, :restrict_clipping_group_size,
      :boolean, null: false, default: false
  end
end
