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
  # https://robots.thoughtbot.com/acceptance-tests-with-subdomains
  # no subdomain by default so that we can just use the public schema
  Capybara.app_host = 'http://college.lvh.me'
  Capybara.always_include_port = true
  Capybara.asset_host = 'http://college.lvh.me:3000'
  Capybara.javascript_driver = :webkit
  ENV['APPLICATION_HOST'] = 'lvh.me:3000'
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

    # setup for Apartment
    # see: https://github.com/influitive/apartment/wiki/Testing-Your-Application
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
    # rubocop:disable RescueModifier
    Apartment::Tenant.drop('college') rescue nil
    # rubocop:enable RescueModifier
    FactoryGirl.create(:college, subdomain: 'college')
  end

  config.before(:each, type: :request) { host! 'college.lvh.me' }

  config.before(:each) do
    DatabaseCleaner.start
    Apartment::Tenant.switch!('college')
  end

  config.after(:each) do
    # Must be rescued for testing lib/user_cloner.rb since that is not meant to
    # be run in a transaction and it breaks this command
    # rubocop:disable RescueModifier
    Apartment::Tenant.reset rescue nil
    # rubocop:enable RescueModifier
    DatabaseCleaner.clean
  end
end

ActiveRecord::Migration.maintain_test_schema!
