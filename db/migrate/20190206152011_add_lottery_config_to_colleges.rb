class AddLotteryConfigToColleges < ActiveRecord::Migration[5.1]
  def change
    add_column :colleges, :size_sort, :integer, default: 0, null: false
    add_column :colleges, :advantage_clips, :boolean, default: false, null: false
    add_column :colleges, :restrict_clipping_group_size, :boolean, null: false, default: false
    add_column :colleges, :allow_clipping, :boolean, default: false, null: false

    remove_column :draws, :restrict_clipping_group_size, :boolean, null: false, default: false
    remove_column :draws, :allow_clipping, :boolean, default: false, null: false
  end
end
