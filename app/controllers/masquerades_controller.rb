# frozen_string_literal: true

# controller for admin masquerades
class MasqueradesController < ApplicationController
  before_action :authorize_admin

  def new
    session[:admin_id] = current_user.id
    user = User.find(params[:user_id])
    sign_in user
    redirect_to root_path
  end

  def end
    user = User.find(session[:admin_id])
    sign_in :user, user
    session[:admin_id] = nil
    msg = { success: 'Stopped masquerading. Welcome back!' }
    handle_action(redirect_object: root_path, msg: msg)
  end

  private

  def authorize_admin
    current_user.admin? || masquerading?
  end

  def authorize!
    authorize :masquerade
  end
end
