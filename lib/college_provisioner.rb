# frozen_string_literal: true

require 'csv'

# Utility class to provision a number of colleges defined in a CSV file;
# automatically copies over the first superuser from the first college into all
# colleges.
class CollegeProvisioner
  include Callable

  # Initialize a new CollegeProvisioner
  #
  # @param filename [String] the filename of a CSV file to read in; it must
  #   contain a header row with "name,subdomain"
  # @param seed [Boolean] whether or not to seed the college with dummy data
  # @param io [IO] the IO device to print to
  def initialize(filename:, seed: false, io: $stdout)
    @lines = CSVReader.read(filename: filename)
    @to_seed = seed
    @io = io
  end

  # Provision a set of colleges from the csv file
  def provision
    check_header
    CSV.parse(lines.join("\n"), headers: true).each do |row|
      provision_and_optionally_seed_college(row)
    end
    # Clone the first superuser, slightly redundant lookup
    UserCloner.clone(username: superuser_username, io: io)
    io.puts 'College provisioning finished!'
  end

  make_callable :provision

  private

  HEADER = %w(name subdomain).freeze

  attr_reader :lines, :to_seed, :io

  def check_header
    return if lines.first.split(',') == HEADER
    io.puts('Invalid CSV file - must include the header "name,subdomain"')
    exit # rubocop:disable Rails/Exit
  end

  def provision_and_optionally_seed_college(row)
    c = create_college(**row.to_hash.symbolize_keys)
    io.puts "#{c.name} college created"
    CollegeSeeder.seed(subdomain: c.subdomain, io: io) if seed?
  end

  def create_college(name:, subdomain:)
    Generator.generate(
      model: 'college', count: 1, name: name, subdomain: subdomain
    ).first
  end

  def superuser_username
    College.first.activate!
    # Use raw SQL to avoid issues with primary key mismatch, see
    # https://github.com/influitive/apartment/issues/508
    result = ActiveRecord::Base.connection.execute <<~SQL
      SELECT users.*
      FROM users
      WHERE users.role = #{User.roles[:superuser]}
      LIMIT 1;
    SQL
    result.first.to_h[User.login_attr.to_s]
  end

  def seed?
    to_seed.present?
  end
end
