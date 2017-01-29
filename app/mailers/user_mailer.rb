# frozen_string_literal: true
#
# Mailer class for general user e-mails
class UserMailer < ApplicationMailer
  default from: 'no-reply@versta.app'

  # Send new account confirmation e-mail. Takes an auto-generated password as an
  # optional parameter.
  #
  # @param user [User] the user to send the confirmation e-mail to
  # @param password [String, nil] the auto-generated password, defaults to nil
  def new_user_confirmation(user:, password: nil)
    @user = user
    @password = password
    @res_college = OpenStruct.new(name: 'College', dean: 'Dean Vesta',
                                  vesta_url: 'https://vesta.app/',
                                  admin_email: 'admin@vesta.app')
    mail(to: @user.email, subject: 'Welcome to Vesta')
  end
end
