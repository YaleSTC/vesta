# frozen_string_literal: true

# Job to update a user's student_id
class SidUpdaterJob < ApplicationJob
  queue_as :default

  # Add a student_id to a user if it exists
  #
  # @param [User] the user to update
  def perform(user:)
    # call querier to get SID
    return unless env?('QUERIER')
    querier = env('QUERIER').constantize.new(id: user.login_attr.to_s)
    attr_hash = querier.query
    # if SID, update user sid field
    return unless attr_hash.key?(:student_id)
    user.update!(student_id: attr_hash[:student_id])
  end
end
