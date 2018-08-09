# frozen_string_literal: true

# Service object to update groups
class GroupUpdater
  include ActiveModel::Model
  include Callable

  validate :suite_size_exists, if: :changing_suite_size

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
    return error(self) unless valid?
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
    find_leader_draw_membership if params[:leader].present?
    cleanup_params
  end

  def users(key) # rubocop:disable AbcSize
    return nil unless params.key? key
    return nil if key == :remove_ids && params[key] == group.leader.id.to_s
    User.active.includes(:draw_membership).find(params[key].reject(&:empty?))
  end

  def find_leader_draw_membership
    dm = DrawMembership.find_by(user_id: params[:leader], active: true)
    @params[:leader_draw_membership] = dm
  end

  def cleanup_params
    params.delete(:member_ids)
    params.delete(:remove_ids)
    params.delete(:leader)
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
      group.draw_memberships << user.draw_membership
    end
  end

  def update_added_user(user)
    user.draw_membership.update!(intent: 'on_campus')
    m = group.memberships.find { |i| i.draw_membership.user_id == user.id }
    m.update!(status: 'accepted') if m.present?
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

  def changing_suite_size
    params[:size].present? && group.size != params[:size].to_i
  end

  def suite_size_exists
    return unless group.draw.present?
    return if group.draw.open_suite_sizes.include? params[:size].to_i
    errors.add :size, 'must be an available suite size in the draw'
  end
end
