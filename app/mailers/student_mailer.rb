# frozen_string_literal: true
#
# Mailer class for student e-mails
class StudentMailer < ApplicationMailer
  # Send initial invitation to students in a draw
  #
  # @param user [User] the user to send the invitation to
  # @param college [College] the college to pull settings from
  def draw_invitation(user:, college: nil)
    determine_college(college)
    @user = user
    @intent_locked = user.draw.intent_locked
    @intent_deadline = format_date(user.draw.intent_deadline)
    mail(to: @user.email, subject: 'The housing process has begun')
  end

  # Send invitation to a group leader to select a suite
  #
  # @param user [User] the group leader to send the invitation to
  # @param college [College] the college to pull settings from
  def selection_invite(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Time to select a suite!')
  end

  # Send notification to a user that their group was deleted
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def disband_notification(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Your housing group has been disbanded')
  end

  # Send notification to a user that their group is finalizing
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def finalizing_notification(user:, college: nil)
    determine_college(college)
    @user = user
    @finalizing_path = if user.group.draw
                         draw_groups_url(user.group)
                       else
                         groups_url(user.group)
                       end
    mail(to: @user.email, subject: 'Confirm your housing group')
  end

  # Send notification to a leader that a user joined their group
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def joined_group(joined:, group:, college: nil)
    determine_college(college)
    @user = group.leader
    @joined = joined
    mail(to: @user.email, subject: "#{joined.full_name} has joined your group")
  end

  # Send notification to a leader that a user left their group
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def left_group(left:, group:, college: nil)
    determine_college(college)
    @user = group.leader
    @left = left
    mail(to: @user.email, subject: "#{left.full_name} has left your group")
  end

  # Send notification to a user that their group is locked
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def group_locked(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Your housing group is now locked')
  end

  # Send reminder to submit housing intent to a user
  #
  # @param user [User] the student to send the reminder to
  # @param college [College] the college to pull settings from
  def intent_reminder(user:, college: nil)
    determine_college(college)
    @user = user
    @intent_date = format_date(user.draw.intent_deadline)
    mail(to: @user.email, subject: 'Reminder to submit housing intent')
  end

  # Send reminder to lock housing group to a user
  #
  # @param user [User] the student to send the reminder to
  # @param college [College] the college to pull settings from
  def locking_reminder(user:, college: nil)
    determine_college(college)
    @user = user
    @locking_date = format_date(user.draw.locking_deadline)
    mail(to: @user.email, subject: 'Reminder to lock housing group')
  end

  private

  def determine_college(college)
    @college = college || College.first || College.new
  end

  def format_date(date)
    return false unless date
    date.strftime('%B %e')
  end
end
