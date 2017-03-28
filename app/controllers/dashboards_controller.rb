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
    @draw_hash = Hash.new { |hash, key| hash[key] = {} }
    @draws.each do |d|
      @draw_hash[d][:partial] = d.status
      if %w(pre_lottery suite_selection results).include? d.status
        send("#{d.status}_metrics".to_sym, d, @draw_hash[d])
      end
    end
  end

  def pre_lottery_metrics(draw, hash) # rubocop:disable MethodLength, AbcSize
    suite_counts = draw.suites.available.group(:size).count
    suite_counts.default = 0
    groups = draw.groups.sort_by { |g| Group.statuses[g.status] }
                 .group_by(&:size)
    groups.default = []
    group_counts = groups.transform_values(&:count)
    group_counts.default = 0
    sizes = (suite_counts.keys + group_counts.keys).uniq.sort
    diff = sizes.map { |s| [s, suite_counts[s] - group_counts[s]] }.to_h

    locked_counts = groups.transform_values { |v| v.select(&:locked?).size }
    locked_counts.default = 0

    hash[:suite_counts] = suite_counts
    hash[:group_counts] = group_counts
    hash[:locked_counts] = locked_counts
    hash[:groups_by_size] = groups
    hash[:sizes] = sizes
    hash[:diff] = diff

    hash[:intent] = IntentMetricsQuery.call(draw)
  end

  def suite_selection_metrics(draw, hash)
    with_suites = draw.groups.joins(:suite)

    with_suite_count = with_suites.count
    no_suite_count = draw.groups.count - with_suite_count
    no_room_count = with_suite_count - with_suites.joins(leader: :room).count

    hash[:next_groups] = draw.next_groups
    hash[:no_suite_count] = no_suite_count
    hash[:with_suite_count] = with_suite_count
    hash[:no_room_count] = no_room_count
  end

  def results_metrics(draw, hash)
    with_suites = draw.groups.joins(:suite)
    no_room_count = with_suites.count - with_suites.joins(leader: :room).count
    hash[:no_room_count] = no_room_count
  end

  def student_variables
    @college = College.first || College.new
    @draw = current_user.draw
    set_deadlines
    group = current_user.group
    @suite = group.suite if group.present?
    @room = current_user.room if @suite.present?
  end

  def set_deadlines
    return unless @draw.present?
    @intent_deadline = @draw.intent_deadline
    @locking_deadline = @draw.locking_deadline
  end

  def authorize!
    authorize Dashboard
  end
end
