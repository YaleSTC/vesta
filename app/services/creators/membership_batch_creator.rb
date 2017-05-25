# frozen_string_literal: true

#
# Class to create memberships for many users with the same attributes
class MembershipBatchCreator
  def self.run(**params)
    new(params).run
  end

  # Create a new MembershipBatchCreator
  #
  # @param [Array] user_ids The ids of users to create memberships for
  # @param [Group] group The group to create memberships in
  # @param [#to_h] params The params for the memberships
  def initialize(user_ids:, group:, **params)
    @users = User.find(user_ids.reject(&:empty?))
    @params = params
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
      MembershipCreator.create!(params.to_h.merge(user: u, group: group))
    end
    build_result
  end

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
    { redirect_object: [group.draw, group], msg: build_flash }
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
      "#{f[:params][:user].full_name} (#{f[:errors].join(', ')})"
    end
    @failure_msg ||= 'Failed to create memberships for '\
      "\n#{@failure_errors.join('\n')}"
  end
end
