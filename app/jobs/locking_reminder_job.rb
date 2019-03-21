# frozen_string_literal: true

# Job to send group locking deadline reminders
class LockingReminderJob < ApplicationJob
  queue_as :default

  # Queues a group locking reminder for each student in the draw
  #
  # @param [Draw] the draw to send reminders in
  def perform(draw:)
    students = draw.students.joins(:draw_membership)
                   .where(draw_memberships:
                          { intent: %w(on_campus undeclared) })
    admins = College.current.users.admin
    (students + admins).each { |s| send_email(user: s, draw: draw) }
  end

  private

  def send_email(user:, draw:)
    locking_deadline = draw.locking_deadline
    StudentMailer.locking_reminder(user: user,
                                   locking_deadline: locking_deadline.to_s)
                 .deliver_now
  end
end
