# frozen_string_literal: true

require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {
      args: %w(--no-sandbox headless disable-gpu --window-size=1280,1280)
    }
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :headless_chrome
