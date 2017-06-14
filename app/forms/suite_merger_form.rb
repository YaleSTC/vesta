# frozen_string_literal: true

#
# Form / service object for merging two suites together. Ensures suites belong
# to the same building.
class SuiteMergerForm
  include ActiveModel::Model
  include Callable

  attr_reader :other_suite_number, :other_suite
  attr_writer :number

  validates :suite, presence: true
  validates :other_suite, presence: { message: 'must be a valid suite' }
  validates :number, presence: true
  validates :other_suite_number, presence: true
  validate :both_suites_different
  validate :both_suites_in_same_building
  validate :both_suites_available

  # Initialize a new SuiteMergerForm
  # @param suite [Suite] the base suite to merge into
  # @param params [#to_h] the form params from the controller
  def initialize(suite:, params: nil)
    @suite = suite
    process_params(params) if params
  end

  # Overwrite number accessor to default to suite number
  #
  # @return [String] passed number from params or suite number if none passed
  def number
    @number ||= suite&.number
  end

  # Perform the suite merging; deletes both suites, creates a new one, assigns
  # all of the rooms from the original suites to the new one, and assigns the
  # new suite to the draw(s) that the original suites belonged to.
  #
  # @return [Hash{Symbol=>String,SuiteMergerForm,Nil,Suite,Hash}] a results hash
  #   for `handle_action`, sets the :redirect_object to either the new suite or
  #   the original suite, :form_object to nil if success or self if failure,
  #   and a flash message
  def submit
    return error(self) unless valid?
    @new_suite = ActiveRecord::Base.transaction do
      rooms = find_combined_rooms
      draws = find_combined_draws
      destroy_and_create_suites(rooms: rooms, draws: draws)
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :submit

  private

  attr_accessor :params, :new_suite, :suite
  attr_writer :other_suite

  def process_params(params)
    @params = params.to_h.transform_keys(&:to_sym)
    @other_suite_number = @params[:other_suite_number]
    @other_suite = find_other_suite
    @params[:number] = '' unless @params[:number]
    @number = @params[:number] unless @params[:number].empty?
  end

  def find_other_suite
    return nil unless suite
    Suite.where(building: suite.building)
         .where('number ILIKE ?', @other_suite_number).includes(:rooms).first
  end

  def both_suites_different
    return unless both_suites_present?
    return if suite.id != other_suite.id
    errors.add(:base, 'Both suites must be different')
  end

  def both_suites_in_same_building
    return unless both_suites_present?
    return if suite.building == other_suite.building
    errors.add(:base, 'Both suites must be in the same building')
  end

  def both_suites_available
    return unless both_suites_present?
    %i(suite other_suite).each do |suite|
      suite_available?(suite)
    end
  end

  def suite_available?(suite_symbol)
    return if send(suite_symbol).available?
    errors.add(suite_symbol, 'must be available')
  end

  def both_suites_present?
    suite.present? && other_suite.present?
  end

  def find_combined_rooms
    return unless both_suites_present?
    suite.rooms + other_suite.rooms
  end

  def find_combined_draws
    return unless both_suites_present?
    (suite.draws + other_suite.draws).uniq
  end

  def destroy_and_create_suites(rooms: [], draws: [])
    destroy_old_suites
    new_suite = Suite.create!(number: number, building: suite.building)
    rooms.each { |room| room.store_original_suite!(suite_id: new_suite.id) }
    draws.each { |draw| draw.suites << new_suite }
    new_suite.reload
  end

  def destroy_old_suites
    suite.destroy!
    other_suite.destroy!
  end

  def success
    {
      redirect_object: new_suite, record: new_suite,
      form_object: nil, msg: { success: 'Suites successfully merged' }
    }
  end

  def error(e)
    msgs = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, form_object: self,
      msg: { error: "Suite merger failed: #{msgs}" }
    }
  end
end
