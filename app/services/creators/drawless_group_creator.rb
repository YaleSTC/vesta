# frozen_string_literal: true
#
# Service object for 'special' (non-draw) housing groups
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
    group = ActiveRecord::Base.transaction do
      ensure_valid_members
      group = Group.new(**params)
      group.save!
      group
    end
    success(group)
  rescue ActiveRecord::RecordInvalid
    error(group.errors.full_messages)
  end

  private

  def process_params
    @params = params.to_h.transform_keys(&:to_sym)
    remove_blank_members if params[:member_ids]
  end

  # TODO: If we end up adding more shared behavior between GroupCreator and this
  # class, don't duplicate and either use inheritance or a module to keep things
  # DRY.
  def remove_blank_members
    @params[:member_ids] = params[:member_ids].reject(&:empty?)
  end

  def ensure_valid_members
    User.where(id: all_member_ids).update_all(draw_id: nil, intent: 'on_campus')
  end

  def all_member_ids
    return params[:leader_id] unless params[:member_ids].present?
    params[:member_ids] + [params[:leader_id]]
  end
end
