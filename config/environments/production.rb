# frozen_string_literal: true

# rubocop:disable BlockLength
require Rails.root.join('config', 'smtp')
Rails.application.configure do
  if ENV.fetch('HEROKU_APP_NAME', '').include?('staging-pr-')
    ENV['APPLICATION_HOST'] = ENV['HEROKU_APP_NAME'] + '.herokuapp.com'
  end
  # make sure that we're always based on our canonical host
  config.middleware.use Rack::CanonicalHost do |env|
    canonical_host = ENV.fetch('APPLICATION_HOST')
    host = env['HTTP_HOST']
    first_subdomain = host.split('.').first
    base_host = host.split('.').drop(1).join('.')
    if host == canonical_host || base_host == canonical_host
      nil
    else
      "#{first_subdomain}.#{canonical_host}"
    end
  end
  # Allow CORS requests for assets
  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins %r{\Ahttps:\/\/.+\.#{ENV.fetch('APPLICATION_HOST')}\z}
      resource '/assets/*', headers: :any, methods: :get
    end
  end
  config.force_ssl = true
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.action_controller.asset_host = ENV.fetch('ASSET_HOST',
                                                  ENV.fetch('APPLICATION_HOST'))
  config.log_level = :debug
  config.log_tags = [:request_id]
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = SMTP_SETTINGS
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
  config.active_record.dump_schema_after_migration = false
  config.middleware.use Rack::Deflater
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31557600'
  }
  config.action_mailer.default_url_options =
    { host: ENV.fetch('APPLICATION_HOST') }
end
Rack::Timeout.timeout = (ENV['RACK_TIMEOUT'] || 10).to_i
