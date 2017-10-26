# frozen_string_literal: true

# Controller for SuiteAssignments
class SuiteAssignmentsController < ApplicationController
  prepend_before_action :set_suite_assignment
  prepend_before_action :set_groups
  prepend_before_action :set_draw

  before_action :set_suites, :set_form_action, only: %i(new)

  def new; end

  def create
    @suite_assignment.prepare(params: suite_assignment_params)
    result = @suite_assignment.assign
    handle_action(path: show_path, **result)
  end

  def destroy
    handle_action(**@suite_assignment.remove)
  end

  private

  def set_form_action
    @url = if bulk_assigning?
             draw_suite_assignment_path(@draw)
           else
             group_suite_assignment_path(@group)
           end
  end

  def show_path
    if bulk_assigning?
      new_draw_suite_assignment_path(@draw)
    elsif @group.draw
      draw_group_path(@group.draw, @group)
    else
      group_path(@group)
    end
  end

  def bulk_assigning?
    @draw.present?
  end

  def set_draw
    return unless params.key? :draw_id
    @draw = Draw.includes(:groups, :suites).find(params[:draw_id])
  end

  def set_groups
    @groups = if bulk_assigning?
                @draw.next_groups
              else
                Group.where(id: params[:group_id])
              end
    handle_action(**DrawResultsStarter.start(draw: @draw)) if @groups.empty?
    @group = @groups.first
    @groups_by_size = create_hash(@groups.group_by(&:size))
  end

  def set_suites
    base = if @group.draw
             @group.draw.available_suites
           else
             Suite.available
           end
    @suites = base.where(size: @groups.map(&:size))
                  .includes(:building, :rooms, :draws)
    @suites_by_size = create_hash(SuitesBySizeQuery.new(@suites).call)
  end

  def set_suite_assignment
    @suite_assignment = SuiteAssignment.new(groups: @groups, draw: @draw)
  end

  def authorize!
    authorize @suite_assignment
  end

  def suite_assignment_params
    params.require(:suite_assignment)
          .permit(:suite, *@suite_assignment.valid_field_ids)
  end

  def create_hash(object_hash)
    Hash.new([]).merge(object_hash)
  end
end
