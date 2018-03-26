# frozen_string_literal: true

# Controller for Dashboards
class DashboardsController < ApplicationController
  before_action :authorize!

  def show
    admin_metrics unless current_user.student?
    student_variables unless current_user.admin?
  end

  private

  def admin_metrics
    @draws = Draw.all.includes(:groups).sort_by(&:name)
                 .map { |d| DrawReport.new(d) }
  end

  def student_variables
    @college = @current_college
    @draw = current_user.draw
    set_deadlines
    set_group_info
  end

  def set_group_info
    @group = current_user.group
    @pending = current_user.memberships if @group.blank?
    @suite = @group.suite if @group.present?
    @room = current_user.room if @suite.present?
  end

  def set_deadlines
    return if @draw.blank?
    @intent_deadline = @draw.intent_deadline
    @locking_deadline = @draw.locking_deadline
  end

  def authorize!
    authorize Dashboard
  end
end
