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

  def process_params # rubocop:disable AbcSize
    @params = params.to_h.transform_keys(&:to_sym)
    add_draw_to_params if params[:leader_id].present?
    remove_blank_members if params[:member_ids].present?
    remove_remove_ids_from_params if params[:remove_ids].present?
  end

  def add_draw_to_params
    @params.merge!(draw_id: User.find(params[:leader_id]).draw.id)
  end

  def remove_blank_members
    @params[:member_ids] = params[:member_ids].reject(&:empty?)
  end

  def remove_remove_ids_from_params
    @params.delete(:remove_ids)
  end

  def success
    {
      object: [obj.draw, obj], group: obj,
      msg: { success: "#{obj.name} created." }
    }
  end

  def error(object = obj)
    errors = object.errors.full_messages
    {
      object: nil, record: obj,
      msg: {
        error: "There was a problem creating the group: #{errors.join(', ')}. "\
        'Please make sure you are not adding too many students.'
      }
    }
  end
end
