class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.integer :size, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.belongs_to :leader, index: true, null: false
      t.belongs_to :draw, index: true, null: false

      t.timestamps
    end
    change_table :users do |t|
      t.belongs_to :group, index: true, null: true
    end
  end
end
