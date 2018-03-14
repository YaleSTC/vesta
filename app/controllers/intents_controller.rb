# frozen_string_literal: true

# Controller for Intents
class IntentsController < ApplicationController
  prepend_before_action :set_draw

  def report
    @students_by_intent = UsersByIntentQuery.new(@draw.students).call
    @intent_metrics = @students_by_intent.transform_values(&:count)
  end

  def export
    @students = @draw.students.order(:intent, :last_name)
    attributes = %I[#{User.login_attr} last_name first_name intent]
    result = CSVGenerator.generate(data: @students, attributes: attributes,
                                   name: 'intents')
    handle_file_action(**result)
  end

  private

  def authorize!
    authorize :intent
  end

  def set_draw
    @draw = Draw.find(params[:draw_id])
  end
end
