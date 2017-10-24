# frozen_string_literal: true

# Controller class for 'special' (admin-created outside of draw) housing groups.
class DrawlessGroupsController < ApplicationController
  prepend_before_action :set_group, except: %i(new create index)
  before_action :set_form_data, only: %i(new edit)

  def show
    if @group.draw.present?
      redirect_to(draw_group_path(@group.draw, @group)) && return
    end
    generate_suites_data

    render layout: 'application_with_sidebar'
  end

  def index
    @groups_by_size = Group.where(draw_id: nil).order(:size).group_by(&:size)
    @sizes = @groups_by_size.keys
  end

  def new; end

  def create
    result = DrawlessGroupCreator.create(params: drawless_group_params)
    @group = result[:record]
    set_form_data unless result[:redirect_object]
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = DrawlessGroupUpdater.update(group: @group,
                                         params: drawless_group_params)
    @group = result[:record]
    set_form_data unless result[:redirect_object]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.destroy(object: @group, name_method: :name)
    handle_action(path: groups_path, **result)
  end

  def lock
    result = GroupLocker.lock(group: @group)
    handle_action(path: group_path(@group), **result)
  end

  def unlock
    result = GroupUnlocker.unlock(group: @group)
    handle_action(path: group_path(@group), **result)
  end

  private

  def authorize!
    @group ? authorize(DrawlessGroup.new(@group)) : authorize(DrawlessGroup)
  end

  def drawless_group_params
    p = params.require(:group).permit(:size, :leader_id, :transfers,
                                      member_ids: [], remove_ids: [])
    return p if @group
    p.reject! { |k, _v| k == 'transfers' }
  end

  def set_group
    @group = Group.includes(:members).find(params[:id])
  end

  def set_form_data
    @group ||= Group.new
    @students = UngroupedStudentsQuery.call
    @leader_students = @group.members.empty? ? @students : @group.members
    @suite_sizes = SuiteSizesQuery.call
  end

  def generate_suites_data
    @compatible_suites = CompatibleSuitesQuery.call(@group).order(:number)
    @compatible_suites_no_draw =
      @compatible_suites.select { |s| s.draws.empty? }.group_by(&:building)
    @compatible_suites_in_draw =
      @compatible_suites.select { |s| s.draws.present? }.group_by(&:building)
  end
end
