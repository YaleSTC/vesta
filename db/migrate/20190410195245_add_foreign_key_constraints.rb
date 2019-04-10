class AddForeignKeyConstraints < ActiveRecord::Migration[5.1]
  def change
  	add_foreign_key :clips, :draws
  	add_foreign_key :draw_suites, :draws
  	add_foreign_key :draw_suites, :suites
  	add_foreign_key :groups, :draws
  	add_foreign_key :memberships, :groups
  	add_foreign_key :rooms, :suites
  	add_foreign_key :suites, :buildings
  end
end
