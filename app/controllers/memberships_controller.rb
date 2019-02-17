# frozen_string_literal: true

# Controller for Memberships
class MembershipsController < ApplicationController
  prepend_before_action :set_group
  prepend_before_action :set_membership,
                        only: %i(update destroy)

  def create
    if params[:create_action] == 'request'
      authorize(Membership.new(group: @group), :request_to_join?)
    end
    result = MembershipCreator.create!(group: @group, user: current_user,
                                       action: params[:create_action])
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def update
    authorize(@membership, :accept?) if params[:update_action] == 'accept'
    authorize(@membership, :finalize?) if params[:update_action] == 'finalize'
    result = MembershipUpdater.update(membership: @membership,
                                      action: params[:update_action])
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def destroy
    result = MembershipDestroyer.destroy(membership: @membership)
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  # TODO: Make #new_invite and create_invite more RESTful
  def new_invite
    @students = @draw.students_with_intent(intents: %w(on_campus))
                     .select { |student| student.group.nil? }
  end

  def create_invite
    batch_params = { user_ids: memberships_params['invitations'], group: @group,
                     action: 'invite' }
    results = MembershipBatchCreator.run(**batch_params)
    handle_action(path: draw_group_path(@draw, @group), **results)
  end

  private

  def authorize!
    if @membership
      authorize @membership
    else
      authorize Membership.new(group: @group)
    end
  end

  def set_group
    key = if %w(new_invite create_invite).include?(params[:action])
            :id
          else
            :group_id
          end
    @group = Group.find(params[key])
    @draw = @group.draw
  end

  def set_membership
    @membership = Membership.find(params[:id])
  end

  def memberships_params
    params.require(:group).permit(invitations: [])
  end
end
