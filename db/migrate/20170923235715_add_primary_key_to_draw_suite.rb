class AddPrimaryKeyToDrawSuite < ActiveRecord::Migration[5.1]
  def change
    rename_table('draws_suites', 'draw_suites_old')

    create_table :draw_suites do |t|
      t.belongs_to :draw, index: true, null: false
      t.belongs_to :suite, index: true, null: false
      t.timestamps
    end

    timestamp = "TIMESTAMP '#{Time.zone.now}'"
    conn = ActiveRecord::Base.connection
    conn.exec_query('select * from draw_suites_old').each_with_index do |ds, i|
      conn.execute('insert into draw_suites '\
                   '(id, draw_id, suite_id, created_at, updated_at) values '\
                   "(#{i}, #{ds['draw_id']}, #{ds['suite_id']}, "\
                   "#{timestamp}, #{timestamp})")
    end

    drop_table('draw_suites_old')
  end
end
