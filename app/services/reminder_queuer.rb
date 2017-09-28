# frozen_string_literal: true

#
# Class to enqueue reminder email jobs
class ReminderQueuer
  include ActiveModel::Model
  include Callable

  validate :correct_reminder_type

  # Initialize a new ReminderQueuer
  #
  # @param draw [Draw] the draw to send reminder emails in
  # @param type [String] type of email to send; must be "intent" or "locking"
  def initialize(draw:, type:)
    @draw = draw
    @type = type
  end

  # Queue the email job
  def queue
    return error(self) unless valid?
    draw.update!(email_type: type, last_email_sent: Time.zone.now)
    queue_job
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :queue

  private

  attr_reader :draw, :type

  REMINDER_JOBS = { 'intent' => IntentReminderJob,
                    'locking' => LockingReminderJob }.freeze

  # NOTE: this happens in the transaction
  def queue_job
    extracted_job_class = REMINDER_JOBS.fetch(type)
    extracted_job_class.perform_later(draw: draw)
  end

  def correct_reminder_type
    return if REMINDER_JOBS.include?(type)
    errors.add(:base, "Invalid reminder type: #{type}")
  end

  def success
    {
      redirect_object: @draw,
      msg: { notice: "Sent #{type} reminders." }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: @draw,
      msg: { error: "Error: #{msg}" }
    }
  end
end
