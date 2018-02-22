class AddTosAcceptanceToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :tos_accepted, :datetime
  end
end
