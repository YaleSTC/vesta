# frozen_string_literal: true

#
# Service object to handle the bulk assignment of suites to groups. Ensures that
# suites are available, groups don't have suites assigned, and optionally that
# suites belong to the appropriate draw.
class BulkSuiteSelectionForm
  include ActiveModel::Model

  validate :all_groups_selected
  validate :no_duplicate_selections
  validate :suites_in_correct_draw

  # Initialize a new BulkSuiteSelectionForm.
  #
  # @param groups [Array<Group>] the groups to assign suites to
  def initialize(groups:)
    @groups = groups
  end

  # Prepare the BulkSuiteSelectionForm by processing form submission params
  #
  # @param params [#to_h] the controller params
  # @return [BulkSuiteSelectionForm] the service object
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
  # @return [Hash{Symbol=>Nil,BulkSuiteSelectionForm,Hash}] the results hash
  def submit
    return error(errors.full_messages.join(', ')) unless valid?
    ActiveRecord::Base.transaction do
      process_all_suite_selections
    end
    success
  rescue ActiveRecord::ActiveRecordError => e
    error(e.to_s)
  end

  # Returns the valid form field ids for a given set of groups
  #
  # @return [Array<Symbol>] the list of form fields
  def valid_field_ids
    return [] unless groups
    @valid_field_ids ||= groups.map { |g| param_for(g) }
  end

  private

  attr_reader :groups, :params

  # note that this occurs in a transaction
  def process_all_suite_selections
    results = groups.each_with_object({}) do |g, hash|
      hash[g] = process_suite_selection(g)
    end
    return unless results.values.none?(&:empty?)
    raise ActiveRecord::ActiveRecordError, errors_from_results(results)
  end

  def process_suite_selection(g)
    suite_id = send(param_for(g))
    selector = SuiteSelector.new(group: g, suite_id: suite_id)
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
      next false if g.draw.suites.available.include? suite
      true
    end
    errors.add(:base, 'All groups in draws must be assigned to suites in '\
      'the same draw')
  end

  def errors_from_results(results_hash)
    results_hash.each_with_object([]) do |(group, results), array|
      next if results.empty?
      array << "#{group.name} - #{results.join(', ')}"
    end.compact.join('; ')
  end

  def success
    msg = 'Suites successfully assigned, please handle the next groups.'
    { redirect_object: nil, service_object: nil, msg: { success: msg } }
  end

  def error(error_msgs)
    {
      redirect_object: nil, service_object: self,
      msg: { error: "There was a problem: #{error_msgs}" }
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
