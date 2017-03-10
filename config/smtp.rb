# frozen_string_literal: true
auth_settings = if ENV['SMTP_AUTH'].present?
                  {
                    authentication: ENV.fetch('SMTP_AUTH').to_sym,
                    user_name: ENV.fetch('SMTP_USERNAME'),
                    password: ENV.fetch('SMTP_PASSWORD')
                  }
                else
                  {}
                end

SMTP_SETTINGS = {
  address: ENV.fetch('SMTP_ADDRESS'), # example: "smtp.sendgrid.net"
  domain: ENV.fetch('SMTP_DOMAIN'), # example: "heroku.com"
  enable_starttls_auto: true,
  port: ENV.fetch('SMTP_PORT')
}.merge(auth_settings).freeze

if ENV['EMAIL_RECIPIENTS'].present?
  Mail.register_interceptor RecipientInterceptor.new(ENV['EMAIL_RECIPIENTS'])
end
