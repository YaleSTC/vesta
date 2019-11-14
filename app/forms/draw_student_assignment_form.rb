# frozen_string_literal: true

#
# Form / service object for adding or removing a single user to/from a draw by
# username. Removes them from their current draw (if they belong to one) and
# saves their previeous draw ID so they can be restored.
class DrawStudentAssignmentForm
  include ActiveModel::Model
  include Callable

  attr_accessor :login, :login_attr, :adding

  validates :login, presence: true
  validates :adding, inclusion: { in: [true, false] }
  validate :student_found
  validate :student_valid

  # Initializes a DrawStudentAssignmentForm
  #
  # @param params [#to_h] parameters from controller
  def initialize(draw:, params: nil)
    @draw = draw
    @adding = true
    @login_attr = User.login_attr
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
      add_student(student)
    else
      student.draw_membership&.restore_draw(save_current: true)&.save!
    end
  end

  def process_params(params)
    @params = params.to_h.symbolize_keys
    @login = @params[:login]&.downcase
    @adding = @params[:adding] == 'true'
    @student = find_student
  end

  def find_student
    return nil unless login
    UngroupedStudentsQuery.call.find_by(login_attr => login)
  end

  def student_found
    return if student
    # This query is needed to find out if a student record exists in our db
    #   but has a group already assigned to it.
    if User.find_by(login_attr => login).present?
      errors.add(
        :username,
        'cannot be added to this draw because they are already in a group.'
      )
    else
      errors.add(:username,
                 "cannot be found. Maybe you haven't imported them yet?")
    end
  end

  def student_valid
    return unless student
    validate_addition if adding?
    validate_removal if removing?
  end

  def validate_addition
    return unless student.draw == draw
    errors.add(:username,
               'must belong to a student outside the draw when adding')
  end

  def validate_removal
    return unless student.draw != draw
    errors.add(:username,
               'must belong to a student in the draw when removing')
  end

  def add_student(student)
    if student.draw_membership.present?
      student.draw_membership&.remove_draw&.update!(draw: draw)
    else
      student.update!(draw: draw)
    end
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
