# frozen_string_literal: true
#
# Users Controller class
class UsersController < ApplicationController
  prepend_before_action :set_user, only: %i(show edit update edit_intent
                                            update_intent)

  def show; end

  def build
    @user = User.new
  end

  def new
    result = UserBuilder.build(id_attr: build_user_params['username'],
                               querier: querier)
    @user = result[:user]
    handle_action(**result)
  end

  def create
    result = UserCreator.new(user_params).create!
    @user = result[:object] ? result[:object] : User.new
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = Updater.new(object: @user, name_method: :name,
                         params: user_params).update
    handle_action(action: 'edit', **result)
  end

  def edit_intent; end

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

  def build_user_params
    params.require(:user).permit(:username)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :role, :email,
                                 :intent, :gender, :username, :class_year,
                                 :college)
  end

  def querier
    return nil unless env?('QUERIER')
    # we can't use the `env` helper because Rails implements a deprecated env
    # method in controllers
    ENV['QUERIER'].constantize
  end
end
