# frozen_string_literal: true

# rubocop:disable Rails/Output

# Helper methods
def generate_colleges
  Generator.generate(model: 'college', count: 1, name: 'Silliman')
end

def generate_users
  if User.cas_auth?
    puts 'Please enter your CAS login: '
    cas_login = $stdin.gets.chomp
    Generator.generate_superuser(username: cas_login)
  else
    Generator.generate_superuser(email: 'email@email.com', password: 'passw0rd')
  end
  Generator.generate(model: 'user', count: 15)
end

def generate_housing_inventory
  Generator.generate(model: 'building', count: 2)
  Generator.generate(model: 'suite', count: 15)

  # generate bedrooms
  Generator.generate(model: 'room', count: 30)

  # generate common rooms
  Generator.generate(model: 'room', count: 10, beds: 0)

  # fix this eventually so that we never generate empty suites
  Suite.where(size: 0).destroy_all
end

def generate_draws
  Generator.generate(model: 'pre_lottery_draw')
  Generator.generate(model: 'lottery_draw')
  Generator.generate(model: 'suite_selection_draw')
end

# Actually seed stuff
if Apartment::Tenant.current == 'public'
  puts 'Generating seed data....'
  puts 'Creating colleges'

  generate_colleges
else
  puts 'Seeding college'
  # This runs for each college
  generate_users
  generate_housing_inventory
  generate_draws
end

puts 'Finished!'
