# frozen_string_literal: true

# Model to represent Housing Draws.
#
# @attr name [String] The name of the housing draw -- e.g. "Junior Draw 2016"
# @attr students [Array<User>] The students in the draw.
# @attr suites [Array<Suite>] The suites in the draw.
# @attr status [String] The status / phase of the draw (draft, pre_lottery,
#   lottery, suite_selection). Note the use of underscores in the status
#   strings; this prevents some unpleasantness with the helper methods.
# @attr locked_sizes [Array<Integer>] the group sizes that are restricted.
# @attr intent_locked [Boolean] True when students in the draw can no longer
#   update their housing intent.
# @attr last_email_sent [Datetime] The time the last reminder email was sent
# @attr email_type [Integer] Enum with the type of the last email sent
#   (currently intent or locking reminders)
# @attr intent_deadline [Datetime] Deadline to set intent. Not strictly
#   enforced, just used for display purposes and sending emails.
# @attr locking_deadline [Datetime] Deadline to lock groups. Not strictly
#   enforced, just used for display purposes and sending emails.
# @attr suite_selection_mode [String] The draw's mode for selecting suites. Can
#   be either "admin_selection" or "student_selection"
# @attr allow_clipping [Boolean] True if the draw allows for clipping,
#  false otherwise.
class Draw < ApplicationRecord # rubocop:disable ClassLength
  has_many :groups
  has_many :students, class_name: 'User', dependent: :nullify
  has_many :draw_suites, dependent: :delete_all
  has_many :suites, through: :draw_suites
  has_many :lottery_assignments, dependent: :destroy
  has_many :clips, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true
  validates :suite_selection_mode, presence: true

  validate :cannot_lock_intent_if_undeclared,
           if: ->() { intent_locked_changed? }

  after_update :destroy_all_clips, if: ->() { saved_change_to_allow_clipping }
  after_destroy :remove_old_draw_ids

  enum status: %w(draft pre_lottery lottery suite_selection results)
  enum email_type: %w(intent locking)
  enum suite_selection_mode: %w(admin_selection student_selection)

  # Finds all available suite sizes within a draw
  #
  # @return [Array<Integer>] the available suite sizes
  def suite_sizes
    @suite_sizes ||= SuiteSizesQuery.new(suites.available).call
  end

  # Finds the sizes that groups exist for within the draw
  #
  # @return [Array<Integer>] the available group sizes
  def group_sizes
    @group_sizes ||= GroupSizesQuery.new(groups).call
  end

  # Finds all suite sizes for which new groups can be created by removing
  # locked_sizes from available sizes
  #
  # @return [Array<Integer>] the suite sizes for which new groups can be created
  def open_suite_sizes
    suite_sizes - locked_sizes
  end

  # Query method get the suites without groups in the draw
  #
  # @return [ActiveRecord::Relation] the suites without assigned groups
  def available_suites
    suites.includes(:rooms).available
  end

  # Query method to see if a draw has at least one student.
  #
  # @return [Boolean] whether or not the draw has at least one student
  def students?
    student_count.positive?
  end

  # Query method to see if a draw has enough beds for its students.
  #
  # @return [Boolean] whether or not the draw has as many or more beds than it
  #   has on-campus students
  def enough_beds?
    bed_count >= on_campus_student_count
  end

  # Query method to see if a draw has at least one group.
  #
  # @return [Boolean] whether or not the draw has at least one group
  def groups?
    group_count.positive?
  end

  # Query method to see if all on-campus students in the draw are in groups
  #
  # @return [Boolean] whether or not all on-campus students are in groups
  def all_students_grouped?
    ungrouped_students.count.zero?
  end

  # Return all ungrouped on-campus or undeclared students for a given draw
  #
  # @return [User::ActiveRecord_Collection] the ungrouped non-off-campus
  #   students in the draw
  def ungrouped_students
    @ungrouped_students ||= UngroupedStudentsQuery.new(
      students.where(intent: %w(undeclared on_campus))
    ).call
  end

  # Query method to see if there are no undeclared students in the draw
  #
  # @return [Boolean] whether or not the draw has no undeclared students
  def all_intents_declared?
    undeclared_count.zero?
  end

  # Query method to see if all the groups in the draw are locked
  #
  # @return [Boolean] whether or not all the groups are locked
  def all_groups_locked?
    groups.all?(&:locked?)
  end

  # Query method to check if all suites are uncontested in other draws
  #
  # @return [Boolean] whether or not all suites are uncontested
  def no_contested_suites?
    suites.includes(:draws).available.all?(&:selectable?)
  end

  # Return the number of students in the draw
  #
  # @return [Integer] the number of students in the draw
  def student_count
    @student_count ||= students.count
  end

  # calculate the number of beds that exist across all available suites
  #
  # @return [integer] the number of beds in all available suites
  def bed_count
    @bed_count ||= suites.available.sum(:size)
  end

  # Returns the number of groups in the draw
  #
  # @return [Integer] the number of groups in the draw
  def group_count
    @group_count ||= groups.count
  end

  # Returns the number of available suites in the draw
  def available_suite_count
    @available_suite_count = suites.available.count
  end

  # Query method to check whether or not a draw is not yet in the lottery phase
  #
  # @return [Boolean] whether or not the draw is not yet in the lottery phase
  def before_lottery?
    %w(draft pre_lottery).include? status
  end

  # Query method to check whether or not a draw is in the lottery phase or after
  #
  # @return [Boolean] whether or not the draw is in or past the lottery phase
  def lottery_or_later?
    %w(lottery suite_selection results).include? status
  end

  # Query method to return whether or not all groups have lottery numbers
  # assigned
  #
  # @return [Boolean] whether or not all groups have lottery numbers
  # assigned
  def lottery_complete?
    groups.all? { |g| g.lottery_number.present? }
  end

  # Query method to check whether or not a draw is oversubscribed by checking
  # all groups. Memoized to avoid querying multiple times per request.
  #
  # @return [Boolean] whether or not the draw is oversubscribed
  def oversubscribed?
    @oversubscribed ||= group_sizes.any? do |size|
      groups.where(size: size).count > suites.where(size: size).count
    end
  end

  # Query method to check whether or not a given group size is locked
  #
  # @param [Integer] the group size to check
  # @return [Boolean] whether or not the group size is locked
  def size_locked?(size)
    locked_sizes.include? size
  end

  # Return the next groups to select suites by lottery number. Returns an empty
  # array if no groups without suites and with lottery numbers exist.
  #
  # @return [Array<Group>] the next available groups using NextGroupsQuery
  def next_groups
    @next_groups ||= NextGroupsQuery.call(draw: self)
  end

  # Returns true if the given group is in the next groups to pick suites
  #
  # @return [Boolean]
  def next_group?(group)
    next_groups.include? group
  end

  # Email the leaders of the next groups to select suites.
  #
  # @param [Mailer] The mailer to use
  def notify_next_groups(mailer = StudentMailer)
    return unless student_selection?
    next_groups.each do |group|
      mailer.selection_invite(user: group.leader).deliver_later
    end
  end

  # Query param to check whether or not all groups have selected suites
  #
  # @return [Boolean] whether or not all groups have selected suites
  def all_groups_have_suites?
    groups.includes(:suite).where(suites: { id: nil }).count.zero?
  end

  private

  def undeclared_count
    @undeclared_count ||= students.undeclared.count
  end

  def on_campus_student_count
    @on_campus_count ||= students.on_campus.count
  end

  def ungrouped_count
    ungrouped_students.count
  end

  # rubocop:disable Rails/SkipsModelValidations
  def remove_old_draw_ids
    User.where(old_draw_id: id).update_all(old_draw_id: nil)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def cannot_lock_intent_if_undeclared
    return if all_intents_declared?
    errors.add :intent_locked, 'Cannot lock intent with undeclared students'
  end

  def destroy_all_clips
    clips.destroy_all
  end
end
