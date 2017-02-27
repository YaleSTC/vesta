class AddLotteryNumberToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :lottery_number, :integer
  end
end
