class AddGroupAssociationToSuites < ActiveRecord::Migration[5.0]
  def change
    add_reference :suites, :group
  end
end
