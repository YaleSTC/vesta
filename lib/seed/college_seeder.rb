# frozen_string_literal: true

# Utility class to seed a specific college with dummy data
class CollegeSeeder
  include Callable

  # Initialize a new CollegeSeeder
  #
  # @param subdomain [String] the subdomain of the college to seed
  # @param io [IO] the IO device to print to
  def initialize(subdomain:, io: $stdout)
    @college = College.find_by!(subdomain: subdomain)
    @io = io
  rescue ActiveRecord::RecordNotFound => _
    io.puts "Invalid college subdomain: #{subdomain}"
    exit # rubocop:disable Rails/Exit
  end

  # Seed the college with housing inventory and students
  def seed
    generate_users
    college.activate!
    generate_housing_inventory
    io.puts "Seeded #{college.name} college!"
  end

  make_callable :seed

  private

  attr_reader :college, :io

  def generate_users
    Generator.generate(model: 'user', count: 30)
  end

  def generate_housing_inventory
    Generator.generate(model: 'building', count: 1)
    Generator.generate(model: 'suite', count: 10)
    Generator.generate(model: 'room', count: 20)
    Generator.generate(model: 'room', count: 5, beds: 0)

    # ensure no empty suites
    Suite.where(size: 0).destroy_all
  end
end
