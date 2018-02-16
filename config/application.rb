# frozen_string_literal: true

# rubocop:disable Style/Documentation
require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)
module Vesta
  class Application < Rails::Application
    config.assets.quiet = true
    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end
    config.action_controller.action_on_unpermitted_parameters = :raise
    config.active_job.queue_adapter = :delayed_job
    services_paths = %w(creators updaters destroyers).map do |s|
      "/app/services/#{s}"
    end
    forms_path = %w(/app/forms)
    presenters_path = %w(/app/presenters)
    lib_paths = %w(/lib) + %w(seed).map { |s| "/lib/#{s}" }
    paths = services_paths + forms_path + presenters_path + lib_paths
    config.eager_load_paths += paths.map { |s| "#{config.root}#{s}" }
    config.time_zone = ENV['RAILS_TIME_ZONE'] || 'UTC'
  end
end
