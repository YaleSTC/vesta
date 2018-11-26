class CreateSuiteAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :suite_assignments do |t|
      t.references :suite, foreign_key: true, null: false
      t.references :group, foreign_key: true, null: false, index: { unique: true }

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        exec_query('INSERT INTO suite_assignments (suite_id, group_id, created_at, updated_at) '\
                   'SELECT id, group_id, created_at, updated_at '\
                   'FROM suites '\
                   'WHERE group_id IS NOT NULL;')
      end

      dir.down do
        exec_query('UPDATE suites SET group_id = '\
                   '(SELECT group_id '\
                   'FROM suite_assignments '\
                   'WHERE suites.id = suite_assignments.suite_id);')
      end
    end

    remove_reference :suites, :group
  end
end
