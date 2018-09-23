# frozen_string_literal: true

#
# Service object to create Groups.
class GroupCreator < DrawlessGroupCreator
  include ActiveModel::Model

  validate :validate_suite_size_inclusion,
           if: ->() { params[:size] }

  private

  attr_accessor :group

  def process_params
    super
    add_draw_to_params
  end

  def add_draw_to_params
    return unless params[:leader_id].present?
    @params.merge!(draw_id: User.find(params[:leader_id]).draw.id)
  end

  def ensure_valid_members; end

  def success
    {
      redirect_object: [group.draw, group], group: group,
      msg: { success: "#{group.name} created." }
    }
  end

  def validate_suite_size_inclusion
    draw = Draw.find(User.find(params[:leader_id]).draw.id)
    return if draw.open_suite_sizes.include? params[:size].to_i
    errors.add :size, 'must be a suite size included in the draw'
  end
end
