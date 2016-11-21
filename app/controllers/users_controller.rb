# frozen_string_literal: true
# Users Controller class
class UsersController < ApplicationController
  before_action :set_user, only: %i(show edit update)

  def show
  end

  def edit
  end

  def update
    @user.assign_attributes(user_params)
    if @user.save
      flash[:notice] = 'User successfully updated.'
      redirect_to @user
    else
      flash[:error] = 'Please review the errors below.'
      render action: 'edit'
    end
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
    params.require(:user).permit(:first_name, :preferred_name, :middle_name,
                                 :last_name, :role, :email)
  end
end
