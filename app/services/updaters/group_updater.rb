# frozen_string_literal: true

# Service object to update groups
class GroupUpdater
  include Callable

  # Instantiates a new DrawlessGroupUpdater
  #
  # @param group [Group] the group
  # @param params [#to_h] the params from the controller
  def initialize(group:, params:)
    @group = group
    process_params(params)
  end

  # Update the group
  #
  # @return [Hash{Symbol=>Group,Hash,Nil}] the return hash
  def update
    ActiveRecord::Base.transaction do
      update_size
      update_members
      group.update!(params)
      group.update_status!
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :update

  private

  attr_accessor :pending_users, :group, :params

  def process_params(params)
    @params = params.to_h.transform_keys(&:to_sym)
    @pending_users = { add: users(:member_ids), remove: users(:remove_ids) }
    delete_user_id_keys_from_params
    delete_leader_id_if_empty
    delete_size_if_empty
  end

  def users(key)
    return nil unless params.key? key
    return nil if key == :remove_ids && params[key] == group.leader_id.to_s
    User.find(params[key].reject(&:empty?))
  end

  def delete_user_id_keys_from_params
    params.delete(:member_ids) if params[:member_ids]
    params.delete(:remove_ids) if params[:remove_ids]
  end

  def delete_leader_id_if_empty
    params[:leader_id] = '' unless params[:leader_id]
    params.delete(:leader_id) if params[:leader_id].empty?
  end

  def delete_size_if_empty
    params.delete(:size) if params[:size].blank?
  end

  # Note that this occurs within the transaction
  def update_members
    remove_users if pending_users[:remove]
    group.reload
    add_users if pending_users[:add]
    group.reload
  end

  def remove_users
    ids = pending_users[:remove].map(&:id)
    group.remove_members!(ids: ids)
  end

  # Note that this occurs within the transaction
  def add_users
    pending_users[:add].each do |user|
      update_added_user(user)
      group.members << user
    end
  end

  def update_added_user(user)
    user.update!(intent: 'on_campus')
  end

  def update_size
    return unless params[:size]
    group.update!(size: params[:size])
    group.reload
  end

  def success
    {
      redirect_object: [group.draw, group], record: group,
      msg: { success: 'Group successfully updated!' }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: nil, record: group,
      msg: { error: "Group update failed: #{msg}" }
    }
  end
end
