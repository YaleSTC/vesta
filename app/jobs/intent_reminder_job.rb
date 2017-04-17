# frozen_string_literal: true

# Job to send intent deadline reminders
class IntentReminderJob < ApplicationJob
  queue_as :default

  # Queues an intent reminder for each student in the draw
  #
  # @param [Draw] the draw to send reminders in
  def perform(draw:)
    students = draw.students.where(intent: %w(undeclared))
    students.each { |s| send_email(s) }
  end

  private

  def send_email(user)
    StudentMailer.intent_reminder(user: user).deliver_now
  end
end
