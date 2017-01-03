class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.belongs_to :group, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
    change_table :users do |t|
      t.remove :group_id
    end
    change_table :groups do |t|
      t.integer :memberships_count, null: false, default: 0
    end
  end
end
