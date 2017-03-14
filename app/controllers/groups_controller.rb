# frozen_string_literal: true
# rubocop:disable Metrics/ClassLength
# Controller for Groups
class GroupsController < ApplicationController
  layout 'application_with_sidebar'
  prepend_before_action :set_group, except: %i(new create)
  prepend_before_action :set_draw
  before_action :set_form_data, only: %i(new edit)

  def show
    @same_size_groups_count = @draw.groups.where(size: @group.size).count
    @compatible_suites = @draw.suites.available.where(size: @group.size)
  end

  def new; end

  def create
    p = group_params.to_h
    p[:leader_id] = current_user.id unless current_user.admin?
    result = GroupCreator.new(p).create!
    @group = result[:group]
    set_form_data unless result[:object]
    handle_action(path: new_draw_group_path(@draw), **result)
  end

  def edit; end

  def update
    result = GroupUpdater.new(group: @group, params: group_params).update
    @group = result[:record]
    set_form_data unless result[:object]
    handle_action(path: edit_draw_group_path(@draw, @group), **result)
  end

  def destroy
    result = Destroyer.new(object: @group, name_method: :name).destroy
    handle_action(**result)
  end

  def request_to_join
    result = MembershipCreator.create!(group: @group, user: current_user,
                                       status: 'requested')
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def accept_request
    user = User.includes(:membership).find(params['user_id'])
    membership = user.memberships.where(group: @group).first
    result = MembershipUpdater.update(membership: membership,
                                      params: { status: 'accepted' })
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def send_invites
    batch_params = { user_ids: group_params['invitations'], group: @group,
                     status: 'invited' }
    results = MembershipBatchCreator.run(**batch_params)
    handle_action(path: draw_group_path(@draw, @group), **results)
  end

  def invite
    @students = UngroupedStudentsQuery.new(@draw.students.on_campus).call
  end

  def accept_invitation
    membership = current_user.memberships.where(group: @group).first
    result = MembershipUpdater.update(membership: membership,
                                      params: { status: 'accepted' })
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def reject_pending
    user = User.includes(:membership).find(params['user_id'])
    membership = user.memberships.find_by(group: @group)
    result = MembershipDestroyer.destroy(membership: membership)
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def leave
    result = MembershipDestroyer.destroy(membership: current_user.membership)
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def finalize
    result = GroupFinalizer.finalize(group: @group)
    handle_action(**result)
  end

  def finalize_membership
    membership = current_user.memberships.where(group: @group).first
    result = MembershipUpdater.update(membership: membership,
                                      params: { locked: true })
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def lock
    result = GroupLocker.lock(group: @group)
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def assign_lottery
    @group.lottery_number = group_params['lottery_number'].to_i
    @color_class = @group.save ? 'success' : 'failure'
  end

  private

  def authorize!
    if @group
      authorize @group
    else
      authorize Group
    end
    authorize @draw, :group_actions?
  end

  def group_params
    p = params.require(:group).permit(:size, :leader_id, :transfers,
                                      :lottery_number, member_ids: [],
                                                       remove_ids: [],
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
    @students = UngroupedStudentsQuery.new(@draw.students.on_campus).call
    @leader_students = @group.members.empty? ? @students : @group.members
    @suite_sizes = @draw.suite_sizes
  end
end
