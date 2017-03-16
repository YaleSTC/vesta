# frozen_string_literal: true
#
# Mailer class for student e-mails
class StudentMailer < ApplicationMailer
  default from: 'no-reply@vesta.site'

  # Send initial invitation to students in a draw
  #
  # @param user [User] the user to send the invitation to
  # @param college [College] the college to pull settings from
  def draw_invitation(user, college)
    @user = user
    @intent_deadline = user.draw.intent_deadline
    @college = college
    mail(to: @user.email, subject: 'The housing process has begun')
  end

  # Send invitation to a group leader to select a suite
  #
  # @param user [User] the group leader to send the invitation to
  # @param college [College] the college to pull settings from
  def selection_invite(user, college)
    @user = user
    @college = college
    mail(to: @user.email, subject: 'Time to select a suite!')
  end
end
