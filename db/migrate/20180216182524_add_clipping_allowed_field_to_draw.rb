class AddClippingAllowedFieldToDraw < ActiveRecord::Migration[5.1]
  def change
    add_column :draws, :allow_clipping, :boolean, default: false, null: false
  end
end
