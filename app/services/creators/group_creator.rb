# frozen_string_literal: true

#
# Service object to create Groups.
class GroupCreator < DrawlessGroupCreator
  validate :validate_users_in_same_draw
  validate :validate_draw_presence

  private

  def process_params
    super
    add_draw_to_params
  end

  def add_draw_to_params
    @draw = Draw.find(params[:leader_draw_membership]&.draw_id)
    @params[:draw] = @draw
  end

  def ensure_valid_members; end

  def success
    {
      redirect_object: [group.draw, group], group: group,
      msg: { success: "#{group.name} created." }
    }
  end

  def validate_suite_size_inclusion
    errors.add :size, 'must be present' unless params[:size].present?
    return if @draw&.open_suite_sizes&.include? params[:size].to_i
    errors.add :size, 'must be an available suite size in the draw'
  end

  def validate_users_in_same_draw
    return unless params[:draw_memberships]&.any?(&:present?)
    return if params[:draw_memberships].map(&:draw_id).uniq.size <= 1
    errors.add(:base, 'Users must all belong to the same draw')
  end

  def validate_draw_presence
    return if @params[:draw].present?
    errors.add(:base, 'Leader must be in a draw.')
  end
end
