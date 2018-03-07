# frozen_string_literal: true

# Controller for user enrollments (bulk-adding)
class EnrollmentsController < ApplicationController
  def new
    @enrollment = Enrollment.new
    @roles = %w(student rep)
  end

  def create
    result = Enrollment.enroll(enrollment_params)
    @enrollment = result[:enrollment]
    handle_action(**result)
  rescue Rack::Timeout::RequestTimeoutException => exception
    Honeybadger.notify(exception)
    handle_idr_timeout
  end

  private

  def authorize!
    authorize Enrollment
  end

  def enrollment_params
    params.require(:enrollment).permit(:ids, :role).to_h
          .transform_keys(&:to_sym).merge(querier: querier)
  end

  def querier
    return nil unless env?('QUERIER')
    # we can't use the `env` helper because Rails implements a deprecated env
    # method in controllers
    ENV['QUERIER'].constantize
  end

  def handle_idr_timeout
    flash[:error] = 'There was a problem with that request, please try again.'
    @enrollment = Enrollment.new
    render action: 'new'
  end
end
