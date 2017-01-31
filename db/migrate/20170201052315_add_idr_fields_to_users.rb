class AddIdrFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.integer :class_year
      t.string :college
    end
  end
end
