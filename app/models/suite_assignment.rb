# frozen_string_literal: true

# Class to handle assigning suites to groups and removing suites from groups
class SuiteAssignment
  include ActiveModel::Model
  extend Forwardable

  validate :all_groups_selected
  validate :no_duplicate_selections
  validate :suites_in_correct_draw

  attr_reader :groups, :draw, :remover_form

  # Initialize a new SuiteAssignment
  #
  # @param groups [Array<Group>] The group(s) whose suite assignment is changing
  # @param draw [Draw] (Optional, used for policies) The groups' draw
  def initialize(groups:, draw: nil)
    @groups = groups
    @draw = draw || groups.first.draw
    @remover_form = SuiteRemover.new(group: groups.first)
    @single = (groups.size == 1)
  end

  def_delegators :@remover_form, :remove

  # Prepare the SuiteAssignment by processing form submission params
  #
  # @param params [#to_h] the controller params
  # @return [SuiteAssignment] the service object
  def prepare(params:)
    @params = params.to_h.transform_keys(&:to_sym)
    @params.each do |k, v|
      next unless respond_to_missing?(k) && !v.empty?
      instance_variable_set("@#{k}", v)
    end
    self
  end

  # Process the suite selections
  #
  # @return [Hash{Symbol=>Nil,SuiteAssignment,Hash}] the results hash
  def assign
    return error(self) unless valid?
    ActiveRecord::Base.transaction { process_all_suite_selections }
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  # Returns the valid form field ids for a given set of groups
  #
  # @return [Array<Symbol>] the list of form fields
  def valid_field_ids
    return [] unless groups
    @valid_field_ids ||= groups.map { |g| param_for(g) }
  end

  private

  attr_reader :params, :single

  SINGLE_SUCCESS_MSG = 'Suite assignment successful'
  SUCCESS_MSG = 'Suites successfully assigned, please handle the next groups.'

  # note that this occurs in a transaction
  def process_all_suite_selections
    results = groups.each_with_object({}) do |g, hash|
      hash[g] = process_suite_selection(g)
    end
    return unless results.values.none?(&:empty?)
    errors_from_results(results)
    raise ActiveRecord::RecordInvalid, self
  end

  def process_suite_selection(g)
    selector = SuiteSelector.new(group: g, suite_id: send(param_for(g)))
    selector.select
    selector.errors
  end

  def all_groups_selected
    return if all_groups_selected?
    errors.add(:base, 'You must select a suite for all groups')
  end

  def all_groups_selected?
    params.values.reject(&:empty?).count == groups.count
  end

  def no_duplicate_selections
    return if params.values.uniq == params.values
    errors.add(:base, 'You must select different suites for each group')
  end

  def suites_in_correct_draw
    return unless all_groups_selected?
    return unless groups.any? do |g|
      next false unless g.draw
      suite = Suite.find_by(id: send(param_for(g)))
      !g.draw.suites.available.include? suite
    end
    errors.add(:base, 'All groups in draws must be assigned to suites in '\
      'the same draw')
  end

  def errors_from_results(results_hash)
    results_hash.each do |group, results|
      next if results.empty?
      errors.add(:base, "#{group.name} - #{results.join(', ')}")
    end
  end

  def success
    msg = single ? SINGLE_SUCCESS_MSG : SUCCESS_MSG
    { redirect_object: nil, service_object: nil, msg: { success: msg } }
  end

  def error(e)
    msg = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, service_object: self,
      msg: { error: "There was a problem: #{msg}" }
    }
  end

  # creates dynamic attr_readers for group fields
  def method_missing(method_name, *args, &block)
    super unless valid_field_ids.include? method_name
    instance_variable_get("@#{method_name}")
  end

  def param_for(group)
    "suite_id_for_#{group.id}".to_sym
  end

  def group_id_from_field(field)
    /suite_id_for_(\d+)$/.match(field)[1].to_i
  end

  def respond_to_missing?(method_name, include_all = false)
    valid_field_ids.include?(method_name) || super
  end
end
