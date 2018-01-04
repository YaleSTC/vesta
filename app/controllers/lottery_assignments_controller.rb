# frozen_string_literal: true

# Controller for LotteryAssignments
class LotteryAssignmentsController < ApplicationController
  prepend_before_action :set_draw_with_eager_load, only: %(index)
  prepend_before_action :set_draw, except: %(index)
  prepend_before_action :set_lottery_assignment, only: %i(update)

  def index; end

  def create
    # don't like this but we need it for the js rendering & we pass it
    # as a hidden value so....
    @group = Group.find(lottery_assignment_params[:group_ids])
    result = Creator.create!(klass: LotteryAssignment,
                             params: lottery_assignment_params,
                             name_method: :number)
    @group.reload # necessary to update the association
    @color_class = result[:msg].keys.first.to_s
  end

  def update
    @group = @lottery_assignment.group
    result = Updater.update(object: @lottery_assignment,
                            params: lottery_assignment_params,
                            name_method: :number)
    @color_class = result[:msg].keys.first.to_s
  end

  private

  def lottery_assignment_params
    params.require(:lottery_assignment).permit(:number, :draw_id, :group_ids)
  end

  def set_lottery_assignment
    @lottery_assignment = LotteryAssignment.includes(:groups).find(params[:id])
  end

  def set_draw_with_eager_load
    @draw = Draw.includes(groups: :leader).includes(:lottery_assignments)
                .find(params[:draw_id])
  end

  def set_draw
    @draw = Draw.find(params[:draw_id])
  end

  def authorize!
    if @lottery_assignment
      authorize @lottery_assignment
    else
      authorize LotteryAssignment.new(draw: @draw)
    end
  end
end
