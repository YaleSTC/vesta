class AddAbbreviationToBuilding < ActiveRecord::Migration[5.1]
  def change
    rename_column(:buildings, :name, :full_name)
    add_column(:buildings, :abbreviation, :string, null: true)
  end
end
