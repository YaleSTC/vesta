# frozen_string_literal: true

# Mailer class for student e-mails
class StudentMailer < ApplicationMailer # rubocop:disable ClassLength
  # Send initial invitation to students in a draw
  #
  # @param user [User] the user to send the invitation to
  # @param college [College] the college to pull settings from
  def draw_invitation(user:, college: nil) # rubocop:disable MethodLength
    determine_college(college)
    @user = user
    @intent_locked = user.draw.intent_locked
    @intent_deadline = format_date(user.draw.intent_deadline)
    @login_str = if User.cas_auth?
                   ''
                 else
                   ' (you will need to use the password reset feature to set '\
                     'your password if you have not logged in before)'
                 end
    mail(to: @user.email, subject: 'The housing process has begun',
         reply_to: @college.admin_email)
  end

  # Send invitation to a group leader to select a suite
  #
  # @param user [User] the group leader to send the invitation to
  # @param college [College] the college to pull settings from
  def selection_invite(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Time to select a suite!',
         reply_to: @college.admin_email)
  end

  # Send notification to a user that their group was deleted
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def disband_notification(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Your housing group has been disbanded',
         reply_to: @college.admin_email)
  end

  # Send notification to a user that their group is finalizing
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def finalizing_notification(user:, college: nil)
    return unless user.group
    determine_college(college)
    @user = user
    @finalizing_url = finalizing_url_for(@user)
    mail(to: @user.email, subject: 'Confirm your housing group',
         reply_to: @college.admin_email)
  end

  # Send notification to a leader that a user has requested to join their group
  #
  # @param requested [User] the user requesting to join
  # @param group [Group] the group the user wants to join
  def requested_to_join_group(requested:, group:)
    determine_college
    @user = group.leader
    @requested = requested
    @group = group
    mail(to: @user.email,
         subject: "#{requested.full_name} wants to join your group",
         reply_to: @college.admin_email)
  end

  # Send notification to a user that they have been invited to join a group
  #
  # @param invited [User] the user invited to join
  # @param group [Group] the group the user wants to join
  def invited_to_join_group(invited:, group:)
    determine_college
    @user = invited
    @group = group
    mail(to: @user.email,
         subject: "#{@group.leader.full_name} invited you to join their group",
         reply_to: @college.admin_email)
  end

  # Send notification to a leader that a user joined their group
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def joined_group(joined:, group:, college: nil)
    determine_college(college)
    @user = group.leader
    @joined = joined
    mail(to: @user.email, subject: "#{joined.full_name} has joined your group",
         reply_to: @college.admin_email)
  end

  # Send notification to a leader that a user left their group
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def left_group(left:, group:, college: nil)
    determine_college(college)
    @user = group.leader
    @left = left
    mail(to: @user.email, subject: "#{left.full_name} has left your group",
         reply_to: @college.admin_email)
  end

  # Send notification to a user that their group is locked
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def group_locked(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Your housing group is now locked',
         reply_to: @college.admin_email)
  end

  # Send reminder to submit housing intent to a user
  #
  # @param user [User] the student to send the reminder to
  # @param college [College] the college to pull settings from
  def intent_reminder(user:, college: nil)
    determine_college(college)
    @user = user
    @intent_date = format_date(user.draw.intent_deadline)
    mail(to: @user.email, subject: 'Reminder to submit housing intent',
         reply_to: @college.admin_email)
  end

  # Send reminder to lock housing group to a user
  #
  # @param user [User] the student to send the reminder to
  # @param college [College] the college to pull settings from
  def locking_reminder(user:, college: nil)
    determine_college(college)
    @user = user
    @locking_date = format_date(user.draw.locking_deadline)
    mail(to: @user.email, subject: 'Reminder to lock housing group',
         reply_to: @college.admin_email)
  end

  # Send an e-mail notifying the student that their lottery number has been
  # assigned
  #
  # @param user [User] the student to send the notification to
  # @param college [College] the college to pull settings from
  def lottery_notification(user:, college:)
    @user = user
    determine_college(college)
    @number = @user.group.lottery_number
    @rank_str = determine_rank_str
    subject = 'Your group has been assigned a lottery number'
    mail(to: @user.email, subject: subject, reply_to: @college.admin_email)
  end

  private

  def determine_college(college = nil)
    @college = college || College.current
  end

  def format_date(date)
    return false unless date.present?
    date.strftime('%B %e')
  end

  def finalizing_url_for(user)
    if user.group.draw.present?
      draw_group_url(user.draw, user.group, host: @college.host)
    else
      group_url(user.group, host: @college.host)
    end
  end

  def determine_rank_str
    count = lottery_numbers.length
    rank = lottery_numbers.index(@number) + 1
    "\##{rank} out of #{count} #{'group'.pluralize(count)} of size "\
      "#{@user.group.size}"
  end

  def lottery_numbers
    @lottery_numbers ||=
      @user.draw.groups.includes(:lottery_assignment)
           .where(size: @user.group.size).map(&:lottery_number).sort
  end
end
