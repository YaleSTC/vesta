# frozen_string_literal: true
#
# Mailer class for student e-mails
class StudentMailer < ApplicationMailer
  default from: 'no-reply@vesta.app'

  # Send initial invitation to students in a draw
  #
  # @param user [User] the user to send the invitation to
  def draw_invitation(user)
    @user = user
    @intent_deadline = user.draw.intent_deadline
    @res_college = OpenStruct.new(name: 'College', dean: 'Dean Vesta',
                                  vesta_url: 'https://vesta.app/',
                                  admin_email: 'admin@vesta.app')
    mail(to: @user.email, subject: 'The housing process has begun')
  end

  # Send invitation to a group leader to select a suite
  #
  # @param user [User] the group leader to send the invitation to
  def selection_invite(user)
    @user = user
    @res_college = OpenStruct.new(name: 'College', dean: 'Dean Vesta',
                                  vesta_url: 'https://vesta.app/',
                                  admin_email: 'admin@vesta.app')
    mail(to: @user.email, subject: 'Time to select a suite!')
  end
end
