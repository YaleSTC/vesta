class CreateSuites < ActiveRecord::Migration[5.0]
  def change
    create_table :suites do |t|
      t.belongs_to :building, index: true
      t.string :number, null: false

      t.timestamps
    end
  end
end
