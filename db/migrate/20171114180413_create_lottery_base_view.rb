class CreateLotteryBaseView < ActiveRecord::Migration[5.0]
  def change
    create_view :lottery_base_views
  end
end
