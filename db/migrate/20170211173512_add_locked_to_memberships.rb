class AddLockedToMemberships < ActiveRecord::Migration[5.0]
  def change
    add_column :memberships, :locked, :boolean, default: false, null: false
  end
end
