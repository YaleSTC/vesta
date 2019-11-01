# frozen_string_literal: true

module Admin
  # Admin dashboard version of the User controller.
  class UsersController < Admin::ApplicationController
    def update
      result = UserUpdater.new(user: requested_resource,
                               params: user_params.tap { |p| proc_params(p) },
                               editing_self: current_user == requested_resource)
                          .update
      @user = result[:record]
      handle_user_updater_result(result)
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :role,
                                   :email, :intent, :gender, :username,
                                   :class_year, :college_id, :password,
                                   :password_confirmation, :current_password,
                                   draw_membership:
                                       %i(draw_id intent old_draw_id))
    end

    def proc_params(p)
      p[:role] = 'student' if p[:role] == 'superuser' &&
                              !current_user.superuser?
    end

    def handle_user_updater_result(result)
      result[:msg].each { |flash_type, msg_str| flash[flash_type] = msg_str }
      result = result.except(:msg)
      if result.delete(:redirect_object).present?
        redirect_to admin_user_path(requested_resource)
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource)
        }
      end
    end
  end
end
