class CreateTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.string :name
      t.timestamps
    end

    create_table :suites_tags, id: false do |t|
      t.belongs_to :tag, index: true
      t.belongs_to :suite, index: true
    end
  end
end

