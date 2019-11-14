# frozen_string_literal: true

#
# Form object to create clips with clip memberships.
class NewClipForm
  include ActiveModel::Model

  validates :draw_id, presence: true
  validates :group_ids,
            length: { minimum: 2,
                      too_short: 'There must be more than one group per clip.' }
  validate :draw_allows_clipping
  validate :matching_draw, if: ->() { clip.present? && group_ids.present? }
  validate :group_not_in_clip, if: ->() { group_ids.present? }

  validate :clip_group_sizes

  attr_reader :draw_id, :group_ids

  # Initialize a NewClipForm
  #
  # @param role [String] current user's role
  # @param params [#to_h] the params for the new clip. Needs a draw_id,
  #   and enough groups_ids to create a valid clip (two without a group, one
  #   with).
  def initialize(role:, params:)
    @role = role
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

  attr_reader :clip, :role

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
    params = params.to_h.symbolize_keys
    @draw_id = params[:draw_id]
    assign_group_ids(params[:group_ids])
    @groups = Group.includes(:draw).where(id: group_ids)
  end

  def create_clip_memberships
    create_membership(id: group_ids.pop, confirmed: true) if role == 'student'
    group_ids.each do |group_id|
      create_membership(id: group_id, confirmed: confirmed_clip?)
    end
  end

  def confirmed_clip?
    %w(admin superadmin superuser).include?(role)
  end

  def create_membership(id:, confirmed:)
    ClipMembership.create!(clip_id: clip.id, group_id: id, confirmed: confirmed)
  end

  def assign_group_ids(group_ids)
    @group_ids = group_ids.present? ? group_ids.reject(&:empty?) : []
  end

  def draw_allows_clipping
    return if College.current.allow_clipping
    errors.add(:base, 'This draw currently does not allow for clipping.')
  rescue ActiveRecord::RecordNotFound
    errors.add(:base, 'Please provide a valid draw_id.')
  end

  def matching_draw
    @groups.each do |group|
      if group.draw != clip.draw
        errors.add :base,
                   "#{group.name} is not in the same draw as the clip"
      end
    end
  end

  def group_not_in_clip
    @groups.each do |group|
      if group.clip
        errors.add :base,
                   "#{group.name} already belongs to another clip"
      end
    end
  end

  def clip_group_sizes
    return unless College.current.restrict_clipping_group_size?
    groups = Group.where(id: group_ids)
    return unless groups.length != groups.where(size: groups.first&.size).length
    msg = 'Groups may only clip together if they are the same size. '\
          'To allow clipping for any group sizes, edit your draw settings.'
    errors.add(:base, msg)
  end
end
