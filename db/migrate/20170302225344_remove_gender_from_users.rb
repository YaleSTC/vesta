class RemoveGenderFromUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.remove :gender
    end
  end
end
