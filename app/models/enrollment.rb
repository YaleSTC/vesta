# frozen_string_literal: true

# Form object for user enrollments (bulk creation / import)
# @attr ids [String] the admin-entered string of multiple user IDs to import
class Enrollment
  include ActiveModel::Model
  include Callable

  attr_reader :successes
  attr_accessor :ids, :ids_array

  validates :ids, presence: true

  # Initialize an Enrollment
  #
  # @param ids [String] the admin-entered string of multiple user IDs to import
  # @param querier [#query] the profile querier service object, see UserBuilder
  #   for more details
  def initialize(ids: '', querier: nil)
    @ids = ids
    @ids_array = process_ids_str(ids)
    @querier = querier
    @successes = []
    @failures = []
    @failed_query_ids = []
    @existing_ids = []
  end

  # Batch-enroll a group of users identified by the `ids` string. Separately
  # handles the following cases:
  #   - Success
  #   - User already existing with the passed id
  #   - Querier not finding a result for the passed id
  #   - User record failing to save for some other reason
  #
  # @return [Hash{Symbol=>Array,Hash,Nil}] a results hash with the message(s) to
  #   set in the appropriate flashes as well as the created user objects and the
  #   controller action to render. Always sets :redirect_object as nil.
  def enroll
    ids_array.each { |id| process_id(id) }
    build_result
  end

  make_callable :enroll

  # View helper to determine whether or not user records will have the :username
  # attribute set (as opposed to checking for CAS directly). Assumes that if the
  # first record created has a username, all users will have a username.
  #
  # @return [Boolean] whether or not the users created will have a username
  #   attribute
  def username?
    successes.first.try(:[], :user).try(:username).present?
  end

  private

  attr_reader :querier
  attr_writer :successes
  attr_accessor :failures, :failed_query_ids

  def process_ids_str(str)
    str.split(delimiter(str)).map(&:strip).map(&:downcase).uniq
  end

  def delimiter(str)
    return ',' if str.include?(',')
    "\n"
  end

  def process_id(id)
    ub = UserBuilder.new(id_attr: id, querier: querier)
    user = ub.build[:user]
    return if ub.exists?
    return failed_query_ids << id if user.first_name.nil?
    if user.save
      successes << { user: user, id: id }
    else
      failures << { user: user, id: id }
    end
  end

  def build_result
    {
      redirect_object: nil, users: successes.map { |s| s[:user] },
      msg: { success: success_msg, alert: alert_msg,
             error: failure_msg },
      action: action_to_render,
      enrollment: self
    }
  end

  def success_msg
    return nil if successes.empty?
    "Successfully created #{success_count} "\
      "#{'user'.pluralize(success_count)}: "\
      "(#{successes.map { |s| s[:id] }.join(', ')})"
  end

  def success_count
    successes.length
  end

  def alert_msg
    return nil if failed_query_ids.empty?
    "The following users could not be found: #{failed_query_ids.join(', ')}"
  end

  def failure_msg
    return nil if failures.empty?
    'The following users could not be saved: '\
      "#{failures.map { |f| f[:id] }.join(', ')}"
  end

  def action_to_render
    return 'new' if successes.empty?
    'results'
  end
end
