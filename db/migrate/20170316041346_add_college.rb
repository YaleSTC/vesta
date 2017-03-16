class AddCollege < ActiveRecord::Migration[5.0]
  def change
    create_table :colleges do |t|
      t.string :name, null: false, index: true
      t.string :dean, null: false
      t.string :admin_email, null: false
      t.string :site_url, null: false

      t.timestamps
    end
  end
end
