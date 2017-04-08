# frozen_string_literal: true

# Service object to split up merged suites into the original suites.
class SuiteUnmerger
  include ActiveModel::Model

  attr_reader :suite, :rooms, :building

  validates :suite, presence: true
  validates :rooms, presence: true
  validates :building, presence: true
  validate :all_rooms_have_original_suite

  # Class method to call #unmerge on a new instance
  def self.unmerge(**params)
    new(**params).unmerge
  end

  # Initialize a new SuiteUnmerger
  #
  # @param suite [Suite] the suite to be unmerged
  def initialize(suite:)
    @building = suite.building
    @suite = suite
    @rooms = suite.rooms
  end

  # Unmerge a suite
  #
  # @return [Hash] The redirect object and flash message
  def unmerge
    return error(errors) unless valid?
    ActiveRecord::Base.transaction do
      create_new_suites!
      suite.destroy!
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e.record.errors)
  end

  private

  def create_new_suites!
    rooms.group_by(&:original_suite).each do |suite_number, rooms|
      Suite.create!(number: suite_number, rooms: rooms, building: building)
    end
  end

  def all_rooms_have_original_suite
    return unless rooms.map(&:original_suite).any?(&:blank?)
    errors.add(:rooms, 'all rooms must have an original suite to split.')
  end

  def success
    {
      object: building,
      msg: { success: 'Suite successfully split' }
    }
  end

  def error(errors)
    {
      object: suite,
      msg: { error: "Suite unmerge failed: #{errors.full_messages.join(' ')}" }
    }
  end
end
