# frozen_string_literal: true
#
# Mailer class for user e-mails
class StudentMailer < ApplicationMailer
  default from: 'no-reply@vesta.app'

  # Send initial invitation to students in a draw
  #
  # @attr user [User] the user to send the invitation to
  def draw_invitation(user)
    @user = user
    @intent_deadline = user.draw.intent_deadline
    @res_college = OpenStruct.new(name: 'College', dean: 'Dean Vesta',
                                  vesta_url: 'https://vesta.app/',
                                  admin_email: 'admin@vesta.app')
    mail(to: @user.email, subject: 'The housing process has begun')
  end
end
