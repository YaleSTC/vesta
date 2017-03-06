class AddLockIntentToDraws < ActiveRecord::Migration[5.0]
  def change
    add_column :draws, :intent_locked, :boolean, null: false, default: false
  end
end
