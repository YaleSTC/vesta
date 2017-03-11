class AddMedicalToSuites < ActiveRecord::Migration[5.0]
  def change
    add_column :suites, :medical, :boolean, default: false
  end
end
