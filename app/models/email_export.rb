# frozen_string_literal: true

# Service / form object for email exports
#
# @attr draw_id [Integer] the draw_id to scope to, if any; set to zero for
#   drawless groups only
# @attr size [Integer,Nil] the size to scope to, if any
# @attr locked [Boolean] whether or not to scope to locked groups only
class EmailExport
  include ActiveModel::Model

  attr_accessor :draw_id, :size, :locked
  attr_reader :leaders

  validates :draw_id, numericality: { only_integer: true, allow_nil: true,
                                      greater_than_or_equal_to: 0 }
  validates :size, numericality: { only_integer: true, allow_nil: true,
                                   greater_than: 0 }
  validates :locked, inclusion: { in: [true, false] }

  # Initialize a new EmailExport, nillifies empty strings for draw_id and
  # converts locked to actual booleans
  def initialize(*args)
    super(*args)
    process_locked
    process_draw_id
  end

  # Generate the e-mail export, collects the relevant groups and their leaders
  #
  # @return [EmailExport] the email export object, will have a leaders attribute
  #   populated with the query results if it succeeded
  def generate
    execute_query if valid?
    self
  end

  # Determine whether or not the query was scoped to a specific draw or to
  # drawless groups
  #
  # @return [Boolean] whether or not the export was scoped to draw_id
  def draw_scoped?
    draw_scope || false
  end

  private

  attr_reader :draw_scope

  def process_locked
    self.locked = locked.to_i == 1 ? true : false
  end

  def process_draw_id
    return unless draw_id.present?
    @draw_scope = true
    self.draw_id = nil if draw_id.to_i.zero?
  end

  def execute_query # rubocop:disable AbcSize
    query = User.includes(:led_group).where.not(groups: { id: nil })
                .order(:last_name, :first_name)
    query = query.where(groups: { draw_id: draw_id }) if draw_scope
    query = query.where(groups: { size: size }) if size.present?
    query = query.where(groups: { status: Group.statuses['locked'] }) if locked
    @leaders = query.to_a
  end
end
