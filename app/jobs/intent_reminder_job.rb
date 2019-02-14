# frozen_string_literal: true

# Job to send intent deadline reminders
class IntentReminderJob < ApplicationJob
  queue_as :default

  # Queues an intent reminder for each student in the draw
  #
  # @param [Draw] the draw to send reminders in
  def perform(draw:)
    students = draw.students.joins(:draw_membership)
                   .where(draw_memberships: { intent: %w(undeclared) })
    admins = College.current.users.admin
    (students + admins).each { |s| send_email(user: s, draw: draw) }
  end

  private

  def send_email(user:, draw:)
    StudentMailer.intent_reminder(user: user, draw: draw).deliver_now
  end
end
