# frozen_string_literal: true

# Service object to update Users
class UserUpdater < Updater
  validate :admin_demote_self
  validate :user_is_not_a_leader_of_a_group
  validate :superusers_and_superadmins_cannot_have_a_college

  # Initialize a UserUpdater
  #
  # @param user [User] The user to be updated
  # @param params [#to_h] The new attributes
  # @param editing_self [Boolean] True if the user is editing themselves,
  #   false otherwise
  def initialize(user:, params:, editing_self:)
    super(object: user, params: params, name_method: :name)
    @editing_self = editing_self
    @needs_warning = user_has_confirmed_a_membership_and_is_changing_college?
    @old_group = object.group
    handle_promotion_or_demotion
  end

  def update
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      object.update!(**params)
      nullify_draw_info if object.saved_change_to_college_id?
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  private

  def handle_promotion_or_demotion
    return if object.role == params[:role]
    handle_promotion
    handle_demotion
  end

  def handle_promotion
    return unless %w(superadmin superuser).include?(params[:role])
    return unless %w(student rep admin).include?(object.role)
    @params[:college_id] = nil
  end

  def handle_demotion
    return unless %w(student rep admin).include?(params[:role])
    return unless %w(superadmin superuser).include?(object.role)
    return if params[:college_id].present?
    @params[:college_id] = College.current.id
  end

  # Checks to see if the user is an admin and trying to change their role
  def admin_demote_self
    return unless @editing_self && @object.admin? && params[:role] != 'admin'
    errors.add(:base, 'You cannot demote yourself.')
  end

  def superusers_and_superadmins_cannot_have_a_college
    return unless %w(superadmin superuser).include?(params[:role])
    return unless object.superadmin? && changing_college?
    errors.add(:base, 'Superusers and Superadmins cannot belong to a college')
  end

  def user_is_not_a_leader_of_a_group
    return unless object.led_group.present? && object.group.size != 1 &&
                  changing_college?
    errors.add(:base, 'This user is the leader of a group. Please change ' \
                'this before continuing.')
  end

  def nullify_draw_info # rubocop:disable AbcSize
    object.group.destroy! if object.group&.size == 1
    object.memberships.map do |m|
      # rubocop:disable Rails/SkipsModelValidations
      m.update_column(:locked, false)
      # rubocop:enable Rails/SkipsModelValidations
      m.destroy!
    end
    object.room_assignment&.destroy!
    object.update!(draw_id: nil, old_draw_id: nil)
  end

  def success
    return super.merge(intent_message) if object.saved_change_to_intent?
    return super unless @needs_warning
    super.merge(warning) { |_, old, new| old.merge(new) }
  end

  def intent_message
    { msg: { notice: 'Intent updated.' } }
  end

  def warning
    alert = "#{object.full_name} was a member of "\
            "#{@old_group.name} in #{College.current.name}; "\
            'please check that this has no repercussions.'
    { msg: { alert: alert } }
  end

  def user_has_confirmed_a_membership_and_is_changing_college?
    object.membership.present? && changing_college?
  end

  def changing_college?
    return false unless params[:college_id].present?
    params[:college_id] != object.college_id.to_s
  end
end
