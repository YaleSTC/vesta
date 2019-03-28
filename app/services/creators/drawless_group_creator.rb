# frozen_string_literal: true

#
# Service object for 'special' (non-draw) housing groups
class DrawlessGroupCreator
  include ActiveModel::Model
  include Callable

  validate :validate_suite_size_inclusion
  validate :validate_draw_membership_presence

  # Initialize a new SpecialGroupCreator
  #
  # @param params [#to_h] the params for the group
  def initialize(params:)
    @params = params.to_h.transform_keys(&:to_sym)
    process_params
    clean_params
  end

  # Attempt to create a new drawless group. Also includes the removal of all
  # members from their draws and the updating of their intents to `on_campus`.
  #
  # @return [Hash{Symbol=>Group,Hash}] a results hash with a message to set in
  #   flash an either `nil` or the created group.
  def create
    @group = Group.new(**params)
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      ensure_valid_members
      group.save!
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :create

  private

  attr_reader :params, :group, :members_to_add

  def process_params # rubocop:disable Metrics/AbcSize
    @params[:member_ids]&.delete_if { |member| member == @params[:leader] }
    @params[:draw_memberships] = find_or_create_draw_memberships
    return unless @params[:draw_memberships].present?
    @params[:leader_draw_membership] = @params[:draw_memberships].select do |dm|
      dm.user_id == params[:leader].to_i
    end.first
  end

  def clean_params
    @params.delete(:member_ids)
    @params.delete(:remove_ids)
    @params.delete(:leader)
  end

  def find_or_create_draw_memberships
    return unless all_member_ids.present?
    all_member_ids.each_with_object([]) do |user_id, array|
      found_dm = DrawMembership.where(user_id: user_id, active: true).first
      dm = found_dm || DrawMembership.new(user_id: user_id, active: true)
      array << dm
    end
  end

  def all_member_ids
    return nil unless params[:leader].present?
    return [params[:leader]] unless params[:member_ids].present?
    (params[:member_ids] + [params[:leader]]).reject(&:empty?)
  end

  # Note that this occurs within the transaction. The call to `update!` will
  # persist any non-persisted draw memberships.
  def ensure_valid_members
    params[:draw_memberships].each do |dm|
      dm.remove_draw.update!(intent: 'on_campus')
    end
  end

  def success
    {
      redirect_object: group, record: group,
      msg: { success: "#{group.name} created." }
    }
  end

  def error(e)
    msg = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, record: group,
      msg: {
        error: "There was a problem creating the group: #{msg}. "\
        'Please make sure you are not adding too many students.'
      }
    }
  end

  def validate_suite_size_inclusion
    errors.add :size, 'must be present' unless params[:size].present?
    return if SuiteSizesQuery.call.include? params[:size].to_i
    errors.add :size, 'must be a valid suite size'
  end

  def validate_draw_membership_presence
    return if params[:draw_memberships]&.all?(&:present?)
    errors.add(:base, 'Users must have a valid draw membership.')
  end
end
