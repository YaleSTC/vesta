# frozen_string_literal: true
class AddActiveToSuites < ActiveRecord::Migration[5.0]
  def change
    add_column :suites, :active, :boolean, null: false, default: true
  end
end
