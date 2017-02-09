# frozen_string_literal: true
#
# Service object to update special (drawless) groups
class DrawlessGroupUpdater < Updater
  # Allows calling of :update on parent class
  def self.update(**params)
    new(**params).update
  end

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
      remove_users if pending_users[:remove]
      group.reload
      add_users if pending_users[:add]
      group.update!(params)
    end
    success
  rescue ActiveRecord::RecordInvalid => error
    error(error)
  end

  private

  attr_accessor :pending_users, :group, :params

  def process_params(params)
    @params = params.to_h.transform_keys(&:to_sym)
    @pending_users = { add: users(:member_ids), remove: users(:remove_ids) }
    delete_user_id_keys_from_params
    delete_leader_id_if_empty
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
    params.delete(:leader_id) if params[:leader_id]
  end

  # Note that this occurs within the transaction
  def remove_users
    Membership.where(user_id: pending_users[:remove].map(&:id)).destroy_all
    pending_users[:remove].each { |user| user.restore_draw.save! }
  end

  # Note that this occurs within the transaction
  def add_users
    pending_users[:add].each do |user|
      user.remove_draw.update!(intent: 'on_campus')
      group.members << user
    end
  end

  def success
    {
      object: group, record: group,
      msg: { success: 'Group successfully updated!' }
    }
  end

  def error(error)
    {
      object: nil, record: group,
      msg: { error: "Group update failed: #{error}" }
    }
  end
end
