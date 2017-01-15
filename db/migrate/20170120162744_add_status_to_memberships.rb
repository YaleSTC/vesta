class AddStatusToMemberships < ActiveRecord::Migration[5.0]
  def change
    add_column :memberships, :status, :integer, null: false, default: 0
  end
end
