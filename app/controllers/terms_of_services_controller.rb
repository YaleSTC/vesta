# frozen_string_literal: true

# Terms of Service Controller class
class TermsOfServicesController < ApplicationController
  skip_before_action :verify_tos_accepted

  def show; end

  def accept
    result = TermsOfServiceAccepter.accept(user: current_user)
    handle_action(**result)
  end

  private

  def authorize!
    authorize :terms_of_service
  end

  def unauthenticated?
    action_name == 'show'
  end
end
