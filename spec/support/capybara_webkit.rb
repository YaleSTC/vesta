# frozen_string_literal: true

Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
  config.allow_url('lvh.me')
  config.allow_url('*.lvh.me')
end
