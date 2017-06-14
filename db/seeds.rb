# frozen_string_literal: true

# rubocop:disable Rails/Output

puts 'Generating seed data....'

Generator.generate(model: 'college', count: 1)
if User.cas_auth?
  puts 'Please enter your CAS login: '
  cas_login = $stdin.gets.chomp
  Generator.generate_admin(username: cas_login)
else
  Generator.generate_admin(email: 'email@email.com', password: 'passw0rd')
end
Generator.generate(model: 'building', count: 2)
Generator.generate(model: 'suite', count: 15)

# generate bedrooms
Generator.generate(model: 'room', count: 30)

# generate common rooms
Generator.generate(model: 'room', count: 10, beds: 0)

Generator.generate(model: 'user', count: 15)

# fix this eventually so that we never generate empty suites
Suite.where(size: 0).destroy_all

Generator.generate(model: 'pre_lottery_draw')
Generator.generate(model: 'lottery_draw')
Generator.generate(model: 'suite_selection_draw')

puts 'Finished!'
