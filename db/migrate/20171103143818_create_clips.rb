class CreateClips < ActiveRecord::Migration[5.1]
  def change
    create_table :clips do |t|
      t.belongs_to :draw, index: true, null: false
      t.timestamps
    end
    create_table :clip_memberships do |t|
      t.belongs_to :clip, index: true, foreign_key: true, null: true
      t.belongs_to :group, index: true, foreign_key: true, null: true
      t.boolean :confirmed, default: false, null: false
    end
  end
end
