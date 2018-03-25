source "https://rubygems.org"

ruby "2.4.3"

gem "autoprefixer-rails", "~> 7.1.1"
gem "delayed_job_active_record", "~> 4.1.2"
gem 'devise', '~> 4.3.0'
gem 'devise_cas_authenticatable', '~> 1.10.0'
gem "flutie"
gem "honeybadger", "~> 3.1.0"
gem "jquery-rails", "~> 4.3.1"
gem "jquery-ui-rails", "~> 6.0.1"
gem "normalize-rails", "~> 4.1.0"
gem "pg", "~> 0.20.0"
gem "puma", "~> 3.9.1"
gem "pundit", "~> 1.1.0"
gem "rack-canonical-host"
gem "rails", "~> 5.1.0"
gem "recipient_interceptor"
gem "sass-rails", "~> 5.0"
gem "simple_form", "~> 3.5.0"
gem "skylight", "~> 1.3.1"
gem "sprockets", ">= 3.0.0"
gem "sprockets-es6"
gem "title"
gem "uglifier", "~> 3.2.0"
gem "scenic", "~> 1.4.0"
gem "apartment", "~> 2.0.0"

# for UserGenerator
gem 'ffaker', '~> 2.5.0'

# Front-End Styling
gem 'foundation-rails', '~> 6.3.0.0'

# Superuser dashboard
gem 'administrate', '~> 0.8.1'

group :development do
  gem "listen"
  gem "spring", "~> 2.0.1"
  gem "spring-commands-rspec"
  gem "web-console", "~> 3.5.0"
  gem "yard", "~> 0.9.11"
end

group :development, :test do
  gem "awesome_print"
  gem "bullet", "~> 5.5.1"
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "dotenv-rails", "~> 2.2.1"
  gem "factory_girl_rails", "~> 4.8.0"
  gem "pry-byebug", "~> 3.4.2"
  gem "pry-rails", "~> 0.3.6"
  gem "rspec-rails", "~> 3.6.0"
  gem "rubocop", "~> 0.49.0", require: false
  gem "rubocop-rspec", "~> 1.15.0", require: false
  # gem 'ruby-progressbar', '~> 1.8.0'
end

group :development, :staging do
  gem "rack-mini-profiler", "~> 0.10.5", require: false
end

group :test do
  gem "capybara-webkit", "~> 1.14.0"
  gem "database_cleaner"
  gem "formulaic", "~> 0.4.0"
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", "~> 0.13", require: false
  gem "codeclimate-test-reporter", "~> 1.0.8"
  gem "timecop"
  gem "webmock"
end

group :staging, :production do
  gem "daemons", "~> 1.2.4"
  gem "rack-timeout"
  gem "rails_stdout_logging"
  gem "rack-cors", "~> 1.0.2"
end

gem 'high_voltage'
