# frozen_string_literal: true
#
# Users Controller class
class UsersController < ApplicationController
  prepend_before_action :set_user, only: %i(show edit update edit_intent
                                            update_intent)

  def show
  end

  def edit
  end

  def update
    result = Updater.new(object: @user, name_method: :name,
                         params: user_params).update
    handle_action(action: 'edit', **result)
  end

  def edit_intent
  end

  def update_intent
    update
  end

  private

  def authorize!
    if @user
      authorize @user
    else
      authorize User
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :role, :email,
                                 :intent, :gender)
  end
end
