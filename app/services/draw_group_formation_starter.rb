# frozen_string_literal: true

# Service object to handle the updating the draw status. Checks to make sure the
# draw has the correct status, updates the status, and sends e-mail invitations
# to students in the draw.
class DrawGroupFormationStarter
  include ActiveModel::Model
  include Callable

  validate :draw_in_intent_selection
  validate :draw_has_students

  # Initialize a new DrawGroupFormationStarter
  #
  # @param draw [Draw] the draw in question
  # @param mailer [ActionMailer::Base] mailer class for sending invitation
  #   e-mails
  def initialize(draw:, mailer: StudentMailer)
    @draw = draw
    @mailer = mailer
    @college = College.current
  end

  # Update a Draw
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the created object.
  def start
    return error(self) unless valid?
    draw.update!(status: 'group_formation')
    send_emails
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :start

  private

  attr_accessor :draw
  attr_reader :college, :mailer

  def draw_in_intent_selection
    return if draw.intent_selection?
    errors.add(:draw, 'must be in intent-selection.')
  end

  def draw_has_students
    return if draw.students?
    errors.add(:draw, 'must have at least one student.')
  end

  def send_emails
    (draw.students + college.users.admin).each do |student|
      mailer.group_formation(user: student, draw: draw, college: college)
            .deliver_later
    end
  end

  def success
    { redirect_object: draw, msg: { notice: 'Draw successfully updated.' } }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: nil,
      msg: { error: "There was a problem updating the draw:\n#{msg}" } }
  end
end
