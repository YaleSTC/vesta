class AddLotteryNumberUniquenessIndex < ActiveRecord::Migration[5.1]
  def change
    add_index(:lottery_assignments, [:draw_id, :number], unique: true)
  end
end
