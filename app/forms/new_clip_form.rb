# frozen_string_literal: true

#
# Form object to create clips with clip memberships.
class NewClipForm
  include ActiveModel::Model

  validates :draw_id, presence: true
  validates :group_ids,
            length: { minimum: 2,
                      too_short: 'There must be more than one group per clip.' }

  attr_reader :draw_id, :group_ids, :add_self

  # Initialize a NewClipForm
  #
  # @param admin [Boolean] true if the current user is an admin, false otherwise
  # @param params [#to_h] the params for the new clip. Needs a draw_id,
  #   enough groups_ids to create a valid clip (two without a group, one
  #   with), and add_self (optional Boolean that determines if the creator
  #   of the clip starts confirmed)
  def initialize(admin:, params:)
    @admin = admin
    process_params(params: params) if params
  end

  # Attempt to create a new clip.  Will rollback if unsuccessful.
  #
  # @return [Hash{Symbol=>Clip,Hash}] A results hash with a message to set in
  #   the flash, either `nil` or the created clip set in :redirect_object,
  #   and either `nil` or the form object in :form_object
  def submit
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      @clip = Clip.create!(draw_id: draw_id)
      create_clip_memberships
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  private

  attr_reader :clip, :admin

  def success
    {
      redirect_object: clip, form_object: nil,
      msg: { success: 'Clip created.' }
    }
  end

  def error(e)
    msg = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, form_object: self,
      msg: { error: "Please review the errors below:\n#{msg}" }
    }
  end

  def process_params(params:)
    params = params.to_h.transform_keys(&:to_sym)
    @draw_id = params[:draw_id]
    @add_self = (params[:add_self] == '1')
    assign_group_ids(params[:group_ids])
  end

  def create_clip_memberships
    create_membership(id: group_ids.pop, confirmed: true) if add_self
    group_ids.each do |group_id|
      create_membership(id: group_id, confirmed: admin)
    end
  end

  def create_membership(id:, confirmed:)
    ClipMembership.create!(clip_id: clip.id, group_id: id, confirmed: confirmed)
  end

  def assign_group_ids(group_ids)
    @group_ids = group_ids.present? ? group_ids.reject(&:empty?) : []
  end
end
