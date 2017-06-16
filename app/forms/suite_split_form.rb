# frozen_string_literal: true

#
# Form / service object for splitting a suite into two or more smaller suites.
# Ensures that all rooms are assigned to new suites and that new suites are
# assigned to the same draws as the original suite.
class SuiteSplitForm
  include ActiveModel::Model
  include Callable

  attr_accessor :suite

  validates :suite, presence: true
  validate :suite_has_at_least_two_rooms, if: ->(f) { f.suite.present? }
  validate :all_room_suite_numbers_present, if: ->(f) { f.suite.present? }

  # Initialize a new SuiteSplitForm
  # @param suite [Suite] the base suite to merge into
  # @param params [#to_h] the form params from the controller
  def initialize(suite:, params: nil)
    @suite = suite
    process_params(params) if params
  end

  # Perform the suite merging; deletes both suites, creates a new one, assigns
  # all of the rooms from the original suites to the new one, and assigns the
  # new suite to the draw(s) that the original suites belonged to.
  #
  # @return [Hash{Symbol=>String,SuiteSplitForm,Nil,Suite,Hash}] a results hash
  #   for `handle_action`, sets the :redirect_object to either the new suite or
  #   the original suite, :form_object to nil if success or self if failure,
  #   and a flash message
  def submit
    return error(self) unless valid?
    @new_suites = ActiveRecord::Base.transaction do
      new_suites = destroy_and_create_suites
      new_suites.map(&:reload)
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :submit

  private

  attr_accessor :params, :new_suites

  def process_params(params)
    @params = params.to_h.transform_keys(&:to_sym)
    valid_method_names.each do |k|
      @params[k] = '' unless @params[k]
      instance_variable_set("@#{k}", @params[k].upcase) unless @params[k].empty?
    end
  end

  def destroy_and_create_suites
    suite_data = archive_suite_data
    suite.destroy!
    new_suites = create_new_suites_in_draws(suite_data)
    suite_data[:rooms].each do |r|
      suite = new_suites.find { |s| s.number == number_for(r) }
      r.update!(suite_id: suite.id)
    end
    new_suites
  end

  def create_new_suites_in_draws(suite_data)
    all_suite_numbers.map do |n|
      s = Suite.create!(number: n, building: suite_data[:building])
      s.draws << suite_data[:draws]
      s
    end
  end

  def archive_suite_data
    {
      rooms: suite.rooms.to_a, draws: suite.draws.to_a,
      building: suite.building
    }
  end

  def suite_has_at_least_two_rooms
    return unless suite.present?
    return unless suite.rooms.size < 2
    errors.add(:suite, 'must have at least two rooms')
  end

  def all_room_suite_numbers_present
    return if valid_method_names.all? { |r| send(r).present? }
    errors.add(:base, 'All rooms must be assigned to a new suite')
  end

  def all_suite_numbers
    @all_suite_numbers ||= valid_method_names.map { |s| send(s) }.uniq.compact
  end

  def number_for(room)
    send(param_for_room(room))
  end

  def success
    {
      redirect_object: nil, form_object: nil, suites: new_suites,
      msg: { success: 'Suite successfully split' }
    }
  end

  def error(e)
    msgs = ErrorHandler.format(error_object: e)
    {
      redirect_object: suite, form_object: self, suites: nil,
      msg: { error: "Suite split failed: #{msgs}" }
    }
  end

  # creates dynamic attr_readers for room suites
  def method_missing(method_name, *args, &block)
    super unless valid_method_names.include? method_name
    instance_variable_get("@#{method_name}")
  end

  def valid_method_names
    return [] unless suite
    @valid_method_names ||= suite.rooms.map { |r| param_for_room(r) }
  end

  def param_for_room(room)
    "room_#{room.id}_suite".to_sym
  end

  def respond_to_missing?(method_name, include_all = false)
    valid_method_names.include?(method_name) || super
  end
end
