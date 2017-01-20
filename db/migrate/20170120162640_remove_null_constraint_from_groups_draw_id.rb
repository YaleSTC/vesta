class RemoveNullConstraintFromGroupsDrawId < ActiveRecord::Migration[5.0]
  def up
    change_column_null :groups, :draw_id, true
  end

  def down
    draw_id = create_null_draw
    change_column_null :groups, :draw_id, false, draw_id
  end

  private

  def create_null_draw
    draw_count = get_null_draw_count
    create_new_null_draw(draw_count + 1)
    get_last_draw_id
  end

  def get_null_draw_count
    result = connection.exec_query(count_null_draws_query)
    result.last.to_hash['count']
  end

  def create_new_null_draw(draw_count)
    connection.exec_insert(create_draw_query(draw_count), nil, [])
  end

  def get_last_draw_id
    result = connection.exec_query(get_last_draw_id_query)
    result.last.to_hash['id']
  end

  def connection
    @connection ||= ActiveRecord::Base.connection
  end

  def count_null_draws_query
    "SELECT count(*) FROM draws WHERE (name LIKE 'null draw%');"
  end

  def create_draw_query(draw_count)
    'INSERT INTO draws (name, created_at, updated_at) VALUES '\
      "('null draw #{draw_count}', '#{Time.zone.now}', '#{Time.zone.now}');"
  end

  def get_last_draw_id_query
    "SELECT draws.id FROM draws ORDER BY draws.id DESC LIMIT 1"
  end
end
