# frozen_string_literal: true

#
# Service objects for group leaders to select a suite for their group.
class GroupSuiteSelector < SuiteSelector
  # Initialize a new GroupSuiteSelector
  #
  # @param group [Group] the group to assign the suite to
  # @param suite_id [Integer] the suite id to assign to the group
  # @param mailer [Mailer] the mailer to use to email next groups
  def initialize(group:, suite_id:, mailer: StudentMailer)
    @mailer = mailer
    super(group: group, suite_id: suite_id)
  end

  # Select / assign a suite to a group. Checks to make sure that the group does
  # not curretly have a suite assigned, that the suite_id corresponds to an
  # existing suite, and that the suite is not currently assigned to a different
  # group. Notifies next groups to select suites.
  #
  # @return [Hash{symbol=>Group,Hash}] a results hash with a message to set in
  #   the flash, nil or the group as the :redirect_object,
  #   and an action to render.
  def select
    return error(self) unless valid?
    suite.update!(group: group)
    notify_next_groups
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :select

  private

  attr_reader :mailer

  def draw
    group.draw
  end

  def notify_next_groups
    return if draw.next_groups.empty?
    return if draw.next_groups.first.lottery_number == group.lottery_number
    draw.notify_next_groups(mailer)
  end

  def success
    {
      redirect_object: [group.draw, group],
      msg: { success: "Suite #{suite.number} assigned to #{group.name}" }
    }
  end
end
