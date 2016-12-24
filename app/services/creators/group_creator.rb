# frozen_string_literal: true
#
# Service object to create Groups.
class GroupCreator < Creator
  # Initialize a new GroupCreator
  #
  # @param params [#to_h] The params for the Group.
  def initialize(params)
    super(klass: Group, name_method: :name, params: params)
    process_params
  end

  private

  def process_params
    @params = params.to_h.transform_keys(&:to_sym)
    add_draw_to_params if params[:leader_id]
    remove_blank_members if params[:member_ids]
  end

  def add_draw_to_params
    @params.merge!(draw_id: User.find(params[:leader_id]).draw.id)
  end

  def remove_blank_members
    @params[:member_ids] = params[:member_ids].reject(&:empty?)
  end

  def success(group)
    { object: [group.draw, group], group: group,
      msg: { notice: "#{group.name} created." } }
  end
end
