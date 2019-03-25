# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def new_user_confirmation
    College.first.activate!
    UserMailer.new_user_confirmation(user: User.first)
  end
end
