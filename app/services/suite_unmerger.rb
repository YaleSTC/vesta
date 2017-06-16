# frozen_string_literal: true

# Service object to split up merged suites into the original suites.
class SuiteUnmerger
  include ActiveModel::Model
  include Callable

  attr_reader :suite

  validates :suite, presence: true
  validates :rooms, presence: true
  validates :building, presence: true
  validate :all_rooms_have_original_suite

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
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      create_new_suites!
      suite.destroy!
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :unmerge

  private

  attr_reader :rooms, :building

  def create_new_suites!
    rooms.group_by(&:original_suite).each do |suite_number, original_rooms|
      Suite.create!(number: suite_number, rooms: original_rooms,
                    building: building)
    end
  end

  def all_rooms_have_original_suite
    return unless rooms.map(&:original_suite).any?(&:blank?)
    errors.add(:rooms, 'must all have an original suite to split.')
  end

  def success
    {
      redirect_object: building,
      msg: { success: 'Suite successfully split into original suites' }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: [building, suite],
      msg: { error: 'Restoring original suites failed: '\
             "#{msg}" }
    }
  end
end
