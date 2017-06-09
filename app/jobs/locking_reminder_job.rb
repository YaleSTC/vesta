# frozen_string_literal: true

# Job to send group locking deadline reminders
class LockingReminderJob < ApplicationJob
  queue_as :default

  # Queues a group locking reminder for each student in the draw
  #
  # @param [Draw] the draw to send reminders in
  def perform(draw:)
    students = draw.students.where(intent: %w(on_campus undeclared))
    students.each { |s| send_email(s) }
  end

  private

  def send_email(user)
    StudentMailer.locking_reminder(user: user).deliver_now
  end
end
