# frozen_string_literal: true

#
# Class to create memberships for many users with the same attributes
class MembershipBatchCreator
  include Callable

  # Create a new MembershipBatchCreator
  #
  # @param [Array] user_ids The ids of users to create memberships for
  # @param [Group] group The group to create memberships in
  # @param [#to_h] params The params for the memberships
  def initialize(user_ids:, group:, **params)
    @users = User.find(user_ids.reject(&:empty?))
    @params = params.to_h
    @group = group
  end

  # Use MembershipCreator to create many memberships. Creates no memberships if
  # creating all of them would exceed the size.
  #
  # @return [Hash{Symbol=>Array,Hash}] A hash with the group and draw to
  #   redirect to and a flash message with the results of the batch create
  def run
    return error if too_many_invitations?
    @results = users.map do |u|
      MembershipCreator.create!(user: u, group: group, **params)
    end
    build_result
  end

  make_callable :run

  private

  attr_reader :users, :successes, :failures, :results, :params, :group

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
