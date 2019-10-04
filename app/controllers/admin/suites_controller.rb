# frozen_string_literal: true

module Admin
  # Admin dashboard equivalent to suites controller
  class SuitesController < Admin::ApplicationController
    def update
      result = Updater.update(
        object: requested_resource,
        params: suite_params,
        name_method: :number
      )
      handle_result(result, :edit)
    end

    def create
      result = Creator.create!(
        klass: Suite,
        params: suite_params,
        name_method: :number
      )
      handle_result(result, :new)
    end

    private

    def suite_params
      p = params.require(:suite).permit(:number, :building_id, :medical,
                                        :group_id, room_ids: [], draw_ids: [])
      p[:group] = Group.find_by(id: p.delete(:group_id))
      p
    end

    def handle_result(result, action) # rubocop:disable AbcSize
      result[:msg].each { |flash_type, msg_str| flash[flash_type] = msg_str }
      result.delete(:msg)
      if result.delete(:redirect_object).present?
        redirect_to admin_suite_path(result[:record] || requested_resource)
      else
        render action, locals: { page: Administrate::Page::Form.new(
          dashboard, result[:record] || requested_resource
        ) }
      end
    end
  end
end
