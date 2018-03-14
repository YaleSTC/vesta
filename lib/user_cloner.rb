# frozen_string_literal: true

# Utility class to clone a user from the first college to all others
class UserCloner
  include Callable

  # Initialize a new SuperuserCloner
  #
  # @param username [String] the identifier for the user to clone; either a
  #   username for CAS auth or an e-mail address otherwise
  # @param from [College] the college to copy the user from (Optional - defaults
  #   to the first college if not passed)
  # @param to [College] a specific college to clone the user to (Optional -
  #   defaults to all other colleges if not passed)
  # @param io [IO] the IO device to print to
  def initialize(username:, from: College.first, to: nil, io: $stdout)
    @io = io
    from.activate!
    @user_attrs = find_user_attrs(field: User.login_attr, value: username)
    @colleges = generate_college_array(from: from, to: to)
  end

  # Clone the user to all colleges, or at least try
  def clone
    colleges.each do |c|
      begin
        clone_user(c)
        io.puts "Cloned #{user_full_name} to #{c.name} college"
      rescue ActiveRecord::RecordNotUnique => _
        io.puts "Unable to clone #{user_full_name} to #{c.name} college - "\
          'user already exists'
        next
      end
    end
  end

  make_callable :clone

  private

  attr_reader :colleges, :io, :user_attrs

  def find_user_attrs(field:, value:) # rubocop:disable MethodLength
    result = ActiveRecord::Base.connection.execute <<~SQL
      SELECT users.*
      FROM users
      WHERE users.#{field} = '#{value}'
      LIMIT 1;
    SQL
    unless result.first.present?
      io.puts "Invalid username: #{value}"
      exit # rubocop:disable Rails/Exit
    end
    result.first.to_h.except!('id').reject! { |_, v| v.blank? }
  end

  def generate_college_array(from:, to:)
    return [to] if to.present?
    College.where.not(id: from.id)
  end

  def clone_user(college)
    college.activate!
    ActiveRecord::Base.connection.execute <<~SQL
      INSERT INTO users (#{user_attrs.keys.join(', ')})
      VALUES (#{user_attrs.values.map { |v| make_sql_safe(v) }.join(', ')});
    SQL
  end

  def make_sql_safe(value)
    return value unless value.class == String
    "'#{value.gsub("'", "''")}'"
  end

  def user_full_name
    "#{user_attrs['first_name']} #{user_attrs['last_name']}"
  end
end
