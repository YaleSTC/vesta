# frozen_string_literal: true

# Job to send intent deadline reminders
class IntentReminderJob < ApplicationJob
  queue_as :default

  # Queues an intent reminder for each student in the draw
  #
  # @param [Draw] the draw to send reminders in
  def perform(draw:)
    students = draw.students_with_intent(intents: %w(undeclared))
    admins = College.current.users.admin
    (students + admins).each { |s| send_email(user: s, draw: draw) }
  end

  private

  def send_email(user:, draw:)
    StudentMailer.intent_reminder(user: user,
                                  intent_deadline: draw.intent_deadline.to_s)
                 .deliver_now
  end
end
