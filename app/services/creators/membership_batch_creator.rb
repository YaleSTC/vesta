# frozen_string_literal: true

#
# Class to create memberships for many users with the same attributes
class MembershipBatchCreator
  include Callable

  # Create a new MembershipBatchCreator
  #
  # @param user_ids [Array] The ids of users to create memberships for
  # @param group [Group] The group to create memberships in
  # @param action [String] The action creating the membership ('invite', etc.)
  def initialize(user_ids:, group:, action:)
    @users = User.active.find(user_ids.reject(&:empty?))
    @group = group
    @action = action
  end

  # Use MembershipCreator to create many memberships. Creates no memberships if
  # creating all of them would exceed the size.
  #
  # @return [Hash{Symbol=>Array,Hash}] A hash with the group and draw to
  #   redirect to and a flash message with the results of the batch create
  def run
    return error if too_many_invitations?
    @results = users.map do |u|
      MembershipCreator.create!(user: u, group: group, action: action)
    end
    build_result
  end

  make_callable :run

  private

  attr_reader :users, :successes, :failures, :results, :group, :action

  def error
    { redirect_object: nil, msg: { error: 'Too many invitations' } }
  end

  def too_many_invitations?
    (group.memberships_count + users.count) > group.size
  end

  def build_result
    @successes, @failures = results.partition { |r| r[:msg].key? :success }
    redirect_object = failures.empty? ? [group.draw, group] : nil
    { redirect_object: redirect_object, msg: build_flash }
  end

  def build_flash
    if successes.empty?
      { error: failure_msg }
    elsif failures.empty?
      { success: success_msg }
    else
      { success: success_msg, error: failure_msg }
    end
  end

  def success_msg
    return if successes.empty?
    @success_msg ||= 'Successfully created memberships for '\
      "#{successes.map { |s| s[:membership].user.full_name }.join(', ')}"
  end

  def failure_msg
    return if failures.empty?
    @failure_errors ||= failures.map do |f|
      "#{f[:params][:user].full_name} (#{f[:errors]})"
    end
    @failure_msg ||= 'Failed to create memberships for '\
      "\n#{@failure_errors.join('\n')}"
  end
end
