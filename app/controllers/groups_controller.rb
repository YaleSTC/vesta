# frozen_string_literal: true
# Controller for Groups
class GroupsController < ApplicationController
  layout 'application_with_sidebar'
  prepend_before_action :set_group, only: %i(show edit update destroy
                                             request_to_join accept_request
                                             invite_to_join edit_invitations
                                             accept_invitation)
  prepend_before_action :set_draw
  before_action :set_form_data, only: %i(new edit)

  def show; end

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

  def invite_to_join
    batch_params = { user_ids: group_params['invitations'], group: @group,
                     status: 'invited' }
    results = MembershipBatchCreator.run(**batch_params)
    handle_action(path: draw_group_path(@draw, @group), **results)
  end

  def edit_invitations
    @students = UngroupedStudentsQuery.new(@draw.students.on_campus).call
  end

  def accept_invitation
    membership = current_user.memberships.where(group: @group).first
    result = MembershipUpdater.update(membership: membership,
                                      params: { status: 'accepted' })
    handle_action(path: draw_group_path(@draw, @group), **result)
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
    params.require(:group).permit(:size, :leader_id, member_ids: [],
                                                     remove_ids: [],
                                                     invitations: [])
  end

  def set_group
    @group = Group.find(params[:id])
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
