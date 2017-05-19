# frozen_string_literal: true

#
# Service object to create Groups.
class GroupCreator < DrawlessGroupCreator
  private

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
end
