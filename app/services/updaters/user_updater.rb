# frozen_string_literal: true

# Service object to update Users
class UserUpdater < Updater
  validate :admin_demote_self
  validate :superusers_and_superadmins_cannot_have_a_college
  validate :user_is_not_in_a_group

  # Initialize a UserUpdater
  #
  # @param user [User] The user to be updated
  # @param params [#to_h] The new attributes
  # @param editing_self [Boolean] True if the user is editing themselves,
  #   false otherwise
  def initialize(user:, params:, editing_self:)
    super(object: user, params: params, name_method: :first_name)
    @editing_self = editing_self
    handle_promotion_or_demotion
  end

  def update # rubocop:disable AbcSize
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      update_intent if params[:intent].present?
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

  def user_is_not_in_a_group
    return unless object.group.present? && changing_college?
    errors.add(:base, "This user is in the group #{object.group.name}." \
                'Please change this before continuing.')
  end

  # This occurs within the transaction
  def update_intent
    object.draw_membership.update!(intent: params[:intent])
    params.delete(:intent)
  end

  def nullify_draw_info
    # We need to unlock accepted memberships before they can be destroyed.
    if object.membership.present?
      # rubocop:disable Rails/SkipsModelValidations
      object.membership.update_column(:locked, false)
      # rubocop:enable Rails/SkipsModelValidations
    end
    object.draw_membership&.destroy!
  end

  def success
    return super.merge(intent_message) if intent_changed?
    super
  end

  def intent_message
    { msg: { notice: 'Intent updated.' } }
  end

  def changing_college?
    return false unless params[:college_id].present?
    params[:college_id] != object.college_id.to_s
  end

  def intent_changed?
    object.draw_membership&.saved_change_to_intent?
  end
end
