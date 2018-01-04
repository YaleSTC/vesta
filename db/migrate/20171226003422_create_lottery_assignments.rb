class CreateLotteryAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :lottery_assignments do |t|
      t.belongs_to :draw, index: true, foreign_key: true
      t.integer :number, null: false
      t.boolean :selected, default: false, null: false

      t.timestamps
    end

    change_table :groups do |t|
      t.belongs_to :lottery_assignment, index: true, foreign_key: true
    end

    timestamp = "TIMESTAMP '#{Time.zone.now}'"

    reversible do |dir|
      dir.up do
        groups = exec_query('SELECT * from groups '\
                            'WHERE draw_id IS NOT NULL '\
                            'AND lottery_number IS NOT NULL')
        groups.each_with_index do |g, i|
          selected = !exec_query('SELECT * from suites WHERE '\
                                 "group_id = #{g['id']}").rows.empty?
          attr = %w(id draw_id number selected created_at updated_at)
          execute("INSERT into lottery_assignments "\
                  "(#{attr.join(', ')}) values "\
                  "(#{i}, #{g['draw_id']}, "\
                  "#{g['lottery_number']}, #{selected}, #{timestamp}, "\
                  "#{timestamp})")
          execute("UPDATE groups SET lottery_assignment_id = #{i}, "\
                  "updated_at = #{timestamp} WHERE id = #{g['id']}")
        end
      end
      dir.down do
        exec_query('SELECT * from groups '\
                   'WHERE lottery_assignment_id IS NOT NULL').each do |g|
          lottery = exec_query('SELECT * from lottery_assignments '\
                               "WHERE id = #{g['lottery_assignment_id']}").first
          execute("UPDATE groups SET lottery_number = #{lottery['number']}, "\
                  "updated_at = #{timestamp} WHERE id = #{g['id']}")
        end
      end
    end

    remove_column :groups, :lottery_number, :integer
  end
end
