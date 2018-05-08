# frozen_string_literal: true

# rubocop:disable Rails/Output

# Helper methods
def generate_colleges
  Generator.generate(model: 'college', count: 1, name: 'Silliman')
end

def generate_superuser
  if User.cas_auth?
    puts 'Please enter your CAS login: '
    cas_login = $stdin.gets.chomp
    Generator.generate_superuser(username: cas_login)
  else
    Generator.generate_superuser(email: 'email@email.com', password: 'passw0rd')
  end
end

def generate_draws
  Generator.generate(model: 'intent_selection_draw')
  Generator.generate(model: 'group_formation_draw')
  Generator.generate(model: 'lottery_draw')
  Generator.generate(model: 'suite_selection_draw')
end

# Actually seed stuff
if Apartment::Tenant.current == 'public'
  puts 'Generating seed data....'
  generate_superuser
  puts 'Creating colleges'
  generate_colleges
elsif Apartment::Tenant.current == 'shared'
else
  puts 'Seeding college'
  # This runs for each college
  CollegeSeeder.seed(subdomain: Apartment::Tenant.current)
  generate_draws
end

puts 'Finished!'
