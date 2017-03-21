class AddLockingDeadlineToDraws < ActiveRecord::Migration[5.0]
  def change
    add_column :draws, :locking_deadline, :date
  end
end
