# frozen_string_literal: true

# Users Controller class
class UsersController < ApplicationController
  prepend_before_action :set_user, except: %i(index new build create)

  def index
    @users = User.includes(:draw).all.order(:class_year, :last_name)
                 .group_by(&:role)
    if @users['student']
      @users['student'] = @users['student'].group_by(&:class_year)
    end
    @users.default = []
  end

  def show; end

  def build
    @user = User.new
  end

  def new # rubocop:disable AbcSize
    redirect_to(build_user_path) && return unless params['user']
    result = UserBuilder.build(id_attr: build_user_params[User.login_attr.to_s],
                               querier: querier)
    @user = result[:user]
    @roles = valid_user_roles
    handle_action(**result)
  rescue Rack::Timeout::RequestTimeoutException => exception
    Honeybadger.notify(exception)
    handle_idr_timeout
  end

  def create
    result = UserCreator.create!(params: user_params)
    @user = result[:user]
    @roles = valid_user_roles unless result[:redirect_object].present?
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = UserUpdater.new(user: @user, params: user_params,
                             editing_self: current_user.id == @user.id).update
    @user = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @user, name_method: :full_name).destroy
    handle_action(path: users_path, **result)
  end

  def edit_intent; end

  def update_intent
    respond_to do |format|
      format.html { update }
      format.js do
        @user.intent = user_params['intent']
        @color_class = @user.save ? 'success' : 'failure'
      end
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

  def build_user_params
    params.require(:user).permit(User.login_attr)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :role, :email,
                                 :intent, :gender, :username, :class_year,
                                 :college).tap { |p| process_params(p) }
  end

  def process_params(p)
    p[:role] = 'student' if p[:role] == 'superuser' && !current_user.superuser?
  end

  def querier
    return nil unless env?('QUERIER')
    # we can't use the `env` helper because Rails implements a deprecated env
    # method in controllers
    ENV['QUERIER'].constantize
  end

  def handle_idr_timeout
    flash[:error] = 'There was a problem with that request, please try again.'
    @user = User.new
    render action: 'build'
  end

  def valid_user_roles
    return User.roles.keys if current_user.superuser?
    User.roles.keys - %w(superuser)
  end
end
