# frozen_string_literal: true

# Controller for Groups
class GroupsController < ApplicationController
  layout 'application_with_sidebar', except: %i(new create edit update index)
  prepend_before_action :set_group, except: %i(new create index)
  prepend_before_action :set_draw
  before_action :authorize_draw!, except: %i(show index)
  before_action :set_form_data, only: %i(new edit)

  def show
    @same_size_groups_count = @draw.groups.where(size: @group.size).count
    @compatible_suites = CompatibleSuitesQuery.new(@draw.available_suites)
                                              .call(@group)
    @compatible_suites_count = @compatible_suites.count
    @clip_invites = @group.clip_memberships.includes(:clip)
                          .where(confirmed: false)
    @membership = @group.memberships.find_by(user: current_user)
  end

  def index
    @groups = @draw.groups.includes(:leader, :members).order('users.last_name')
                   .group_by(&:size).sort.to_h
  end

  def new; end

  def create
    p = group_params.to_h
    p[:leader_id] = current_user.id if current_user.student?
    result = GroupCreator.create(params: p)
    @group = result[:record]
    set_form_data unless result[:redirect_object]
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = GroupUpdater.update(group: @group, params: group_params)
    @group = result[:record]
    set_form_data unless result[:redirect_object]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @group, name_method: :name).destroy
    path = params[:redirect_path] || draw_path(@draw)
    handle_action(**result, path: path)
  end

  def finalize
    result = GroupFinalizer.finalize(group: @group)
    handle_action(**result)
  end

  def lock
    result = GroupLocker.lock(group: @group)
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def unlock
    result = GroupUnlocker.unlock(group: @group)
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def make_drawless
    result = GroupDrawRemover.remove(group: @group)
    handle_action(action: 'show', **result)
  end

  private

  def authorize!
    if @group
      authorize @group
    else
      authorize Group
    end
  end

  def authorize_draw!
    authorize @draw, :group_actions?
  end

  def group_params
    p = params.require(:group).permit(:size, :leader_id, :transfers,
                                      :lottery_number, :suite,
                                      member_ids: [], remove_ids: [],
                                      invitations: [])
    return p if @group
    p.reject! { |k, _v| k == 'transfers' }
  end

  def set_group
    @group = Group.includes(:memberships).find(params[:id])
  end

  def set_draw
    @draw = Draw.find(params[:draw_id])
  end

  def set_form_data
    @group ||= Group.new(draw: @draw)
    @group.members.delete_all unless @group.persisted?
    @students = UngroupedStudentsQuery.new(@draw.students.on_campus).call
    @leader_students = @group.members.empty? ? @students : @group.members
    @suite_sizes = @draw.open_suite_sizes
  end
end
