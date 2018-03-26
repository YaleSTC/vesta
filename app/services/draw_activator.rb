# frozen_string_literal: true

# Service object to handle the activation of a draw. Checks to make sure the
# draw has the correct status, updates the status, and sends e-mail invitations
# to students in the draw.
class DrawActivator
  include ActiveModel::Model
  include Callable

  validate :draw_in_a_draft
  validate :draw_has_students

  # Initialize a new DrawActivator
  #
  # @param draw [Draw] the draw in question
  # @param mailer [ActionMailer::Base] mailer class for sending invitation
  #   e-mails
  def initialize(draw:, mailer: StudentMailer)
    @draw = draw
    @mailer = mailer
    @college = College.current
  end

  # Activate a Draw
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the created object.
  def activate
    return error(self) unless valid?
    draw.update!(status: 'pre_lottery')
    send_emails
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :activate

  private

  attr_accessor :draw
  attr_reader :college, :mailer

  def draw_in_a_draft
    return if draw.draft?
    errors.add(:draw, 'must be a draft.')
  end

  def draw_has_students
    return if draw.students?
    errors.add(:draw, 'must have at least one student.')
  end

  def send_emails
    draw.students.each do |student|
      mailer.draw_invitation(user: student, college: college).deliver_later
    end
  end

  def success
    { redirect_object: draw, msg: { notice: 'Draw successfully initiated.' } }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: nil,
      msg: { error: "There was a problem initiating the draw:\n#{msg}" } }
  end
end
