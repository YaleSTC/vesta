# frozen_string_literal: true

module Admin
  # Administrate dashboard mirror of the Group controller.
  class GroupsController < Admin::ApplicationController
    def update
      result = GroupUpdater.update(
        group: requested_resource,
        params: group_params
      )
      handle_group_updater_result(result)
    end

    private

    def group_params
      p = params.require(:group).permit(:size, :leader_id, :transfers,
                                        :lottery_number, :suite,
                                        :draw_id, :status,
                                        member_ids: [], remove_ids: [],
                                        invitations: [])
      p[:leader] = p.delete(:leader_id)
      p
    end

    def handle_group_updater_result(result) # rubocop:disable AbcSize
      result[:msg].each { |flash_type, msg_str| flash[flash_type] = msg_str }
      result.delete(:msg)
      if result.delete(:redirect_object).present?
        redirect_to admin_group_path(requested_resource)
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard,
                                             Group.find(requested_resource.id))
        }
      end
    end
  end
end
