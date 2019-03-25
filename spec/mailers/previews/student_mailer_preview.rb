# frozen_string_literal: true

class StudentMailerPreview < ActionMailer::Preview
  def draw_invitation_intent_locked
    College.first.activate!
    StudentMailer.draw_invitation(user: User.first, intent_locked: true,
                                  intent_deadline: Time.zone
                                                       .now)
  end

  def draw_invitation_intent_unlocked
    College.first.activate!
    StudentMailer.draw_invitation(user: User.first, intent_locked: false,
                                  intent_deadline: Time.zone
                                                       .now)
  end

  def group_formation_with_intent_locked
    College.first.activate!
    StudentMailer.group_formation(user: User.first, intent_locked: true,
                                  intent_deadline: Time.zone
                                                       .now)
  end

  def group_formation_with_intent_unlocked
    College.first.activate!
    StudentMailer.group_formation(user: User.first, intent_locked: false,
                                  intent_deadline: Time.zone
                                                       .now)
  end

  def selection_invite
    College.first.activate!
    StudentMailer.selection_invite(user: User.first)
  end

  def disband_notification
    College.first.activate!
    StudentMailer.disband_notification(user: User.first)
  end

  def finalizing_notification
    College.first.activate!
    StudentMailer.finalizing_notification(user: Group.first.leader)
  end

  def requested_to_join_group
    College.first.activate!
    StudentMailer.requested_to_join_group(requested: User.first, group: Group
                                                                        .first)
  end

  def invited_to_join_group
    College.first.activate!
    StudentMailer.invited_to_join_group(invited: User.first, group: Group.first)
  end

  def joined_group
    College.first.activate!
    StudentMailer.joined_group(joined: User.first, group_leader: Group.first
                                                                      .leader)
  end

  def left_group
    College.first.activate!
    StudentMailer.left_group(left: User.first, group_leader: Group.first.leader)
  end

  def group_locked
    College.first.activate!
    StudentMailer.group_locked(user: User.first)
  end

  def intent_reminder
    College.first.activate!
    StudentMailer.intent_reminder(user: User.first, intent_deadline: Time.zone
                                                                         .now)
  end

  def locking_reminder
    College.first.activate!
    StudentMailer.locking_reminder(user: User.first, locking_deadline: Time.zone
                                                                           .now)
  end

  def lottery_notification
    College.first.activate!
    StudentMailer.lottery_notification(user: User.first, college: College.first)
  end
end
