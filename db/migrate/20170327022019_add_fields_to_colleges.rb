class AddFieldsToColleges < ActiveRecord::Migration[5.0]
  def change
    change_table :colleges do |t|
      t.string :floor_plan_url
      t.text :student_info_text
    end
  end
end
