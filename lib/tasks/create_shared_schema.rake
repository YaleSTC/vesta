# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
namespace :db do
  desc 'create a new schema with the name of "shared"'
  task create_shared_schema: :environment do
    ActiveRecord::Base.configurations.each_value do |configuration|
      next unless configuration.key?('database')
      ActiveRecord::Base.establish_connection(configuration)
      ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared;'
      ActiveRecord::Base.connection.execute 'GRANT usage ON SCHEMA shared to public;'
      ActiveRecord::Base.connection.schema_search_path = 'shared'
      load(Rails.root.join('db', 'schema.rb'))
    end
  end
end

Rake::Task['db:schema:load'].enhance [:create_shared_schema]
Rake::Task['db:test:load_schema'].enhance [:create_shared_schema]
