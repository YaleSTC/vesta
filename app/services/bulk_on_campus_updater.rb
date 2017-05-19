# frozen_string_literal: true

# Service object to set all undeclared students in a draw to on_campus intent
class BulkOnCampusUpdater
  include Callable

  # Initialize a new instance of BulkOnCampusUpdater
  #
  # @param draw [Draw] the draw in question
  def initialize(draw:)
    @draw = draw
  end

  # Perform the bulk intent update
  #
  # @return [Hash{Symbol=>Draw,Hash}] a results hash with the draw assigned to
  #   :redirect_object and a success flash message
  def update
    put_all_undeclared_students_on_campus
    success
  end

  make_callable :update

  private

  attr_reader :draw

  def put_all_undeclared_students_on_campus
    draw.students.where(intent: 'undeclared')
        .map { |u| u.update(intent: 'on_campus') }
  end

  def success
    { redirect_object: draw,
      msg: { success: 'All undeclared students set to live on-campus' } }
  end
end
