# frozen_string_literal: true

# Service object to duplicate an existing draw by coping all of the
# associatied suites into a new draw.
class DrawDuplicator
  include ActiveModel::Model
  include Callable

  validate :draw_name_free

  # Initialize a Draw Duplicator
  #
  # @param draw [Draw] the draw to be duplicated
  def initialize(draw:)
    @old_draw = draw
  end

  # Runs the duplicator to create a new draw with the same associations
  # as the old draw
  def duplicate
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      create_draw_copy
      add_suites_to(new_draw)
    end
    success
  rescue ActiveRecord::ActiveRecordError => e
    error(e)
  end

  make_callable :duplicate

  private

  attr_reader :old_draw
  attr_accessor :new_draw

  def add_suites_to(new_draw)
    old_draw.suites.each do |suite|
      new_draw.suites << suite
    end
  end

  def create_draw_copy
    @new_draw = Creator.create!(klass: Draw, params: draw_params,
                                name_method: :name)[:redirect_object]
  end

  def draw_params
    { name: old_draw.name + '-copy' }
  end

  def success
    { redirect_object: new_draw,
      msg: { success: 'Draw successfully duplicated' } }
  end

  def draw_name_free
    return unless Draw.find_by(draw_params)
    errors.add(:base, 'A copy of this draw already exists')
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: old_draw,
      msg: { error: "There was a problem duplicating this draw:\n#{msg}" } }
  end
end
