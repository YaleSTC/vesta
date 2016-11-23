class CreateDraws < ActiveRecord::Migration[5.0]
  def change
    create_table :draws do |t|
      t.string :name
      t.timestamps
    end
    create_join_table :draws, :suites do |t|
      t.index :draw_id
      t.index :suite_id
    end
    change_table :users do |t|
      t.belongs_to :draw, index: true, null: true
    end
  end
end
