# frozen_string_literal: true
# rubocop:disable Rails/Output

puts 'Generating seed data....'

Generator.generate_admin(email: 'email@email.com', password: 'passw0rd')
Generator.generate(model: 'building', count: 2)
Generator.generate(model: 'suite', count: 15)

# generate bedrooms
Generator.generate(model: 'room', count: 30)
# generate common rooms
Generator.generate(model: 'room', count: 10, beds: 0)

Generator.generate(model: 'user', count: 15)

# fix this eventually so that we never generate empty suites
Suite.where(size: 0).destroy_all

Generator.generate(model: 'draw', count: 3)

puts 'Finished!'
