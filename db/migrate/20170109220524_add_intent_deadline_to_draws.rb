class AddIntentDeadlineToDraws < ActiveRecord::Migration[5.0]
  def change
    add_column :draws, :intent_deadline, :date
  end
end
