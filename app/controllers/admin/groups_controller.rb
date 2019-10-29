# frozen_string_literal: true

module Admin
  # Administrate dashboard mirror of the Group controller.
  class GroupsController < Admin::ApplicationController
    def update
      result = GroupUpdater.update(
        group: requested_resource,
        params: group_params
      )
      handle_result(result, :edit)
    end

    def create
      result = GroupCreator.new(params: group_params).create
      handle_result(result, :new)
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

    def handle_result(result, action)
      result[:msg].each { |flash_type, msg_str| flash[flash_type] = msg_str }
      if result.delete(:redirect_object).present?
        redirect_to admin_group_path(result[:record] || requested_resource)
      else
        render action, locals: { page: Administrate::Page::Form.new(
          dashboard, result[:record] || requested_resource
        ) }
      end
    end
  end
end
