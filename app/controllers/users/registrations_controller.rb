class Users::RegistrationsController < Devise::RegistrationsController

  def create
	build_resource(sign_up_params)
    if resource.save
      redirect_to '/'
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    '/' # Or :prefix_to_your_route
  end

  def after_sign_up_path_for(resource)
    '/' # Or :prefix_to_your_route
  end

end