# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)
abort('DATABASE_URL environment variable is set') if ENV['DATABASE_URL']

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'pundit/rspec'

SUPPORT_PATH = %w(spec support ** *.rb).freeze

Dir[Rails.root.join(*SUPPORT_PATH)].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  include Formulaic::Dsl
  # Capybara Config
  include Capybara::DSL
  Capybara.asset_host = 'http://0.0.0.0:3000'
  Capybara.javascript_driver = :webkit
end

RSpec.configure do |config|
  config.include Features, type: :feature
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  # DatabaseCleaner set up
  config.use_transactional_fixtures = false
  config.before(:suite) do
    # By default, do not use CAS in tests unless we specifically override ENV.
    ENV.delete('CAS_BASE_URL')
    # Remove all PROFILE_REQUESTER keys from ENV to avoid issuing requests
    ENV.delete_if { |k, _v| !k.match(/PROFILE_REQUEST_/).nil? }
    ENV['MAILER_FROM'] = 'foo@example.com'
    DatabaseCleaner.clean_with(:deletion)
  end
  config.before(:each) { DatabaseCleaner.strategy = :transaction }
  config.before(:each, js: true) { DatabaseCleaner.strategy = :truncation }
  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }
end

ActiveRecord::Migration.maintain_test_schema!
