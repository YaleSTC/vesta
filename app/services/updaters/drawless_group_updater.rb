# frozen_string_literal: true
#
# Service object to update special (drawless) groups
class DrawlessGroupUpdater < GroupUpdater
  private

  # Note that this occurs within the transaction
  def remove_users # rubocop:disable Metrics/AbcSize
    ids = pending_users[:remove].map(&:id)
    group.memberships.where(user_id: ids).delete_all
    group.decrement!(:memberships_count, ids.size)
    group.update_status!
    pending_users[:remove].each { |user| user.restore_draw.save! }
  end

  # Note that this occurs within the transaction
  def update_added_user(user)
    user.remove_draw.update!(intent: 'on_campus')
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
