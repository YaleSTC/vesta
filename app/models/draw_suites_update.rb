# frozen_string_literal: true

# Form / service object to handle the updating of draw suites
class DrawSuitesUpdate
  include ActiveModel::Model
  include Callable

  CONSOLIDATED_ATTRS = %i(suite_ids drawn_ids drawless_ids).freeze

  attr_reader(*CONSOLIDATED_ATTRS)

  # Initialize a new DrawSuitesUpdate
  #
  # @param draw [Draw] the draw to be updated
  # @param params [#to_h] the parameters from the form
  def initialize(draw:, params: nil)
    @draw = draw
    prepare_current_suite_attrs
    @suite_ids = draw.suites.available.map(&:id)
    process_params(params) if params
  end

  # Execute the suites update, remove all suites to be removed and add all
  # suites to be added. Occurs in a transaction for safety.
  #
  # @return [Hash{Symbol=>String,Hash,Nil,DrawStringUpdate] a result hash
  #   containing the appropriate path to redirect to, a flash message to set,
  #   and the DrawSuitesUpdate object if there were any failures.
  def update
    return no_action_warning if suites_to_remove.empty? && suites_to_add.empty?
    ActiveRecord::Base.transaction do
      remove_suites unless suites_to_remove.empty?
      add_suites unless suites_to_add.empty?
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :update

  private

  attr_reader :draw, :params, :suites_to_add, :suites_to_remove

  def prepare_current_suite_attrs
    suites_by_size = draw.suites.available.group_by(&:size)
    suite_hash = suites_by_size.transform_values { |v| v.map(&:id) }
    suite_hash.each do |size, ids|
      instance_variable_set("@suite_ids_#{size}", ids)
    end
  end

  def process_params(params)
    @params = consolidate_params(params.to_h.transform_keys(&:to_sym))
    CONSOLIDATED_ATTRS.each { |attr| update_ids_param(attr) }
    @suites_to_remove = find_suites_to_remove
    @suites_to_add = find_suites_to_add
  end

  def consolidate_params(p)
    p.transform_values! { |v| v.nil? ? [] : v }
    CONSOLIDATED_ATTRS.each do |attr|
      consolidated_array = p.each_with_object([]) do |(k, v), array|
        array << v if k.to_s.include? attr.to_s
        array
      end.flatten
      p.merge!(attr => consolidated_array)
    end
    p
  end

  def update_ids_param(key)
    params[key].reject!(&:empty?)
  end

  def find_suites_to_remove
    return [] unless params[:suite_ids]
    # TODO: refactor not to require an extra db hit here, also makes testing
    # better
    current_suite_ids = draw.suites.available.map(&:id)
    passed_suite_ids = params[:suite_ids].map(&:to_i)
    Suite.find(current_suite_ids - passed_suite_ids)
  end

  def find_suites_to_add
    return [] unless params[:drawn_ids] || params[:drawless_ids]
    Suite.find(params[:drawn_ids] + params[:drawless_ids])
  end

  def remove_suites
    suites_to_remove.each { |suite| draw.suites.destroy(suite) }
  end

  def add_suites
    suites_to_add.each { |suite| draw.suites << suite }
  end

  def no_action_warning
    { redirect_object: nil, update_object: self,
      msg: { alert: 'No changes selected' } }
  end

  def success
    {
      redirect_object: nil, update_object: nil,
      msg: { success: 'Suites successfully updated' }
    }
  end

  def error(e)
    msg = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, update_object: self,
      msg: { error: "Suites update failed: #{msg}" }
    }
  end

  # create dynamic attr_readers based on available suite sizes
  def method_missing(method_name, *args, &block)
    super unless valid_method_names.include? method_name
    instance_variable_get("@#{method_name}")
  end

  def valid_method_names
    @valid_method_names ||= all_suite_sizes.map { |s| params_for(s) }.flatten
  end

  def all_suite_sizes
    @all_suite_sizes ||= SuiteSizesQuery.new(Suite.available).call
  end

  def params_for(size)
    CONSOLIDATED_ATTRS.map { |p| "#{p}_#{size}".to_sym }
  end

  def respond_to_missing?(method_name, include_all = false)
    valid_method_names.include?(method_name) || super
  end
end
