# frozen_string_literal: true
#
# Service object for 'special' (non-draw) housing groups
# TODO: If we end up adding more shared behavior between GroupCreator and this
# class, don't duplicate and either use inheritance or a module to keep things
# DRY.
class DrawlessGroupCreator < Creator
  # Initialize a new SpecialGroupCreator
  #
  # @param params [#to_h] the params for the group
  def initialize(params)
    super(klass: Group, name_method: :name, params: params)
    process_params
  end

  # Attempt to create a new drawless group. Also includes the removal of all
  # members from their draws and the updating of their intents to `on_campus`.
  #
  # @return [Hash{Symbol=>Group,Hash}] a results hash with a message to set in
  #   flash an either `nil` or the created group.
  def create!
    ActiveRecord::Base.transaction do
      ensure_valid_members
      @obj = Group.new(**params)
      @obj.save!
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e.record)
  end

  private

  def process_params
    @params = params.to_h.transform_keys(&:to_sym)
    remove_blank_members if params[:member_ids]
    remove_remove_ids_from_params if params[:remove_ids]
  end

  def remove_blank_members
    @params[:member_ids] = params[:member_ids].reject(&:empty?)
  end

  def remove_remove_ids_from_params
    @params.delete(:remove_ids)
  end

  # Note that this occurs within the transaction
  def ensure_valid_members
    User.where(id: all_member_ids).each do |user|
      user.remove_draw.update!(intent: 'on_campus')
    end
  end

  def all_member_ids
    return params[:leader_id] unless params[:member_ids].present?
    params[:member_ids] + [params[:leader_id]]
  end
end
