# frozen_string_literal: true

#
# Service object to update clip memberships
class ClipMembershipUpdater < Updater
  validate :freeze_clip, if: -> { params.key?(:clip) }
  validate :freeze_clip_id, if: -> { params.key?(:clip_id) }
  validate :freeze_group, if: -> { params.key?(:group) }
  validate :freeze_group_id, if: -> { params.key?(:group_id) }
  validate :freeze_status, if: -> { params.key?(:confirmed) }

  # Initialize a ClipMembershipUpdater
  #
  # @param clip_membership [ClipMembership] clip membership object to be updated
  # @param params [#to_h] new attributes
  def initialize(clip_membership:, params:)
    super(object: clip_membership, name_method: nil, params: params)
  end

  private

  def freeze_status
    return if object.clip.draw.status == 'group_formation'
    errors.add(:draw, 'must be in group formation phase.')
  end

  def freeze_clip
    return if params[:clip] == object.clip
    errors.add(:clip, 'cannot be changed in clip membership.')
  end

  def freeze_clip_id
    return if params[:clip_id] == object.clip_id
    errors.add(:clip, 'cannot be changed in clip membership.')
  end

  def freeze_group
    return if params[:group] == object.group
    errors.add(:group, 'cannot be changed in clip membership.')
  end

  def freeze_group_id
    return if params[:group_id] == object.group_id
    errors.add(:group, 'cannot be changed in clip membership.')
  end

  # This success message assumes that the only update to a clip membership
  # is from unconfirmed -> confirmed
  def success
    { redirect_object: [object.group.draw, object.group],
      msg: { success: "#{object.group.name} joined #{object.clip.name}." } }
  end
end
