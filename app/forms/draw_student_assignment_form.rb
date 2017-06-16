# frozen_string_literal: true

#
# Form / service object for adding or removing a single user to/from a draw by
# username. Removes them from their current draw (if they belong to one) and
# saves their previeous draw ID so they can be restored.
class DrawStudentAssignmentForm
  include ActiveModel::Model
  include Callable

  attr_accessor :username, :adding

  validates :username, presence: true
  validates :adding, inclusion: { in: [true, false] }
  validate :student_found
  validate :student_valid

  # Initializes a DrawStudentAssignmentForm
  #
  # @param params [#to_h] parameters from controller
  def initialize(draw:, params: nil)
    @draw = draw
    @adding = true
    process_params(params) if params
  end

  # Execute the student update, either adding or removing the student in
  # question. If the username is invalid or belongs to a user in a group,
  # returns an error.
  #
  # @return Hash{Symbol=>Nil,DrawStudentAssignmentForm,Hash} a result hash
  #   containing nil for the :redirect_object, the DrawStudentAssignmentForm
  #   set to :update_object if there were any failures, and a flash message
  def submit
    return error(self) unless valid?
    update_students
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :submit

  private

  attr_reader :draw, :student

  def update_students
    if adding?
      student.remove_draw.update!(draw_id: draw.id)
    else
      student.restore_draw(save_current: true).save!
    end
  end

  def process_params(params)
    @params = params.to_h.transform_keys(&:to_sym)
    @username = @params[:username]
    @adding = @params[:adding] == 'true'
    @student = find_student
  end

  def find_student
    return nil unless username
    UngroupedStudentsQuery.call.find_by(username: username)
  end

  def student_found
    return if student
    errors.add(:username, 'must belong to a student not in a group')
  end

  def student_valid
    return unless student
    validate_addition if adding?
    validate_removal if removing?
  end

  def validate_addition
    return unless student.draw_id == draw.id
    errors.add(:username,
               'must belong to a student outside the draw when adding')
  end

  def validate_removal
    return unless student.draw_id != draw.id
    errors.add(:username,
               'must belong to a student in the draw when removing')
  end

  def success
    verb = adding? ? 'added' : 'removed'
    {
      redirect_object: nil, update_object: nil,
      msg: { success: "#{student.full_name} successfully #{verb}" }
    }
  end

  def error(e)
    msgs = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, update_object: self,
      msg: { error: "Student update failed: #{msgs}" }
    }
  end

  def adding?
    adding
  end

  def removing?
    !adding?
  end
end
