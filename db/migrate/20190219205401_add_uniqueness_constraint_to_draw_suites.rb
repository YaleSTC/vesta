class AddUniquenessConstraintToDrawSuites < ActiveRecord::Migration[5.1]
  def change
    # Remove duplicate draw_suites and keep the one with the lowest id
    execute <<-SQL
      DELETE
      FROM
        draw_suites a
            USING draw_suites b
      WHERE
        a.id > b.id
        AND a.draw_id = b.draw_id
        AND a.suite_id = b.suite_id;
    SQL

    add_index(:draw_suites, [:draw_id, :suite_id], unique: true)
  end
end
