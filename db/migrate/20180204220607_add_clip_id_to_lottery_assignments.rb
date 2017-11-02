class AddClipIdToLotteryAssignments < ActiveRecord::Migration[5.1]
  def change
    change_table :lottery_assignments do |t|
      t.belongs_to :clip, index: true, foreign_key: true
    end
  end
end
