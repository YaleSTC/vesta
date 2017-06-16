# frozen_string_literal: true

#
# Service object for 'special' (non-draw) housing groups
class DrawlessGroupCreator
  include Callable

  # Initialize a new SpecialGroupCreator
  #
  # @param params [#to_h] the params for the group
  def initialize(params:)
    @params = params.to_h.transform_keys(&:to_sym)
    process_params
  end

  # Attempt to create a new drawless group. Also includes the removal of all
  # members from their draws and the updating of their intents to `on_campus`.
  #
  # @return [Hash{Symbol=>Group,Hash}] a results hash with a message to set in
  #   flash an either `nil` or the created group.
  def create
    ActiveRecord::Base.transaction do
      ensure_valid_members
      @group = Group.new(**params)
      @group.save!
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :create

  private

  attr_reader :klass, :params, :name_method, :group

  def process_params
    @params = params.to_h.transform_keys(&:to_sym)
    remove_blank_members
    remove_remove_ids_from_params
  end

  def remove_blank_members
    return unless params[:member_ids]
    @params[:member_ids] = params[:member_ids].reject(&:empty?)
  end

  def remove_remove_ids_from_params
    return unless params[:remove_ids]
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
end
