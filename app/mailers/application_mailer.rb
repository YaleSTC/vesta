# frozen_string_literal: true

#
# Base Mailer class
class ApplicationMailer < ActionMailer::Base
  default from: ->() { vesta_sender }
  default reply_to: College&.first&.admin_email
  layout 'mailer'

  private

  def vesta_sender
    address = Mail::Address.new env('MAILER_FROM')
    address.display_name = env('MAILER_FROM_NAME') if env?('MAILER_FROM_NAME')
    address.format
  end
end
