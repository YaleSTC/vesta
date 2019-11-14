# frozen_string_literal: true

# Form / service object to handle the updating of draw students
class DrawStudentsUpdate
  include ActiveModel::Model
  include Callable

  attr_reader :class_year

  # Initialize a new DrawStudentsUpdate
  #
  #
  # @param draw [Draw] the draw to be updated
  # @param params [#to_h] the parameters from the form
  def initialize(draw:, params: nil)
    @draw = draw
    process_params(params) if params
  end

  # Execute the students update, adding all students specified to the draw.
  # Occurs in a transaction for safety.
  #
  # @return [Hash{Symbol=>String,Hash,Nil,DrawStringUpdate] a result hash
  #   containing the appropriate path to redirect to, a flash message to set,
  #   and the DrawStudentsUpdate object if there were any failures.
  def update
    return no_action_warning if students_to_add.empty?
    ActiveRecord::Base.transaction do
      # update_all doesn't work since we have a left outer join in our ungrouped
      # students query
      students_to_add.each { |s| s.update!(draw: draw) }
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :update

  private

  attr_reader :draw, :params, :students_to_add

  def process_params(params)
    @params = params.to_h.symbolize_keys
    @params[:class_year] = nil if @params[:class_year]&.empty?
    @class_year = set_class_year
    @students_to_add = students_to_add_by_class_year
  end

  def set_class_year
    return nil unless params[:class_year]
    params[:class_year].to_i
  end

  def students_to_add_by_class_year
    return [] unless class_year
    UngroupedStudentsQuery.call.includes(:draw_membership)
                          .where(class_year: class_year,
                                 draw_memberships: { draw_id: nil })
  end

  def no_action_warning
    { redirect_object: nil, update_object: self,
      msg: { alert: 'No changes selected' } }
  end

  def success
    {
      redirect_object: nil, update_object: nil,
      msg: { success: 'Students successfully updated' }
    }
  end

  def error(e)
    msg = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, update_object: self,
      msg: { error: "Student assignment failed: #{msg}" }
    }
  end
end
