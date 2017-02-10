# frozen_string_literal: true
#
# Form / service object to handle the updating of draw suites
class DrawSuitesUpdate
  include ActiveModel::Model

  attr_reader :size, :suite_ids, :drawn_suite_ids, :undrawn_suite_ids

  # permit :update to be called on the class object
  def self.update(**params)
    new(**params).update
  end

  # Initialize a new DrawSuitesUpdate
  #
  # @param draw [Draw] the draw to be updated
  # @param params [#to_h] the parameters from the form
  def initialize(draw:, params: nil)
    @draw = draw
    @suite_ids = draw.suite_ids
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
  rescue ActiveRecord::RecordInvalid => error
    error(error)
  end

  private

  attr_reader :draw, :params, :suites_to_add, :suites_to_remove

  def process_params(params)
    @params = params.to_h.transform_keys(&:to_sym)
    @size = extract_size
    update_ids_param(:suite_ids)
    update_ids_param(:drawn_suite_ids)
    update_ids_param(:undrawn_suite_ids)
    @suites_to_remove = find_suites_to_remove
    @suites_to_add = find_suites_to_add
  end

  def extract_size
    raise ArgumentError if size_param_not_an_int
    params[:size].to_i
  end

  def size_param_not_an_int
    params[:size].to_s.match(/\d+/).nil?
  end

  def update_ids_param(key)
    params[key] = [] unless params[key]
    @params[key] = params[key].reject(&:empty?)
  end

  def find_suites_to_remove
    return [] unless params[:suite_ids]
    # TODO: refactor not to require an extra db hit here, also makes testing
    # better
    current_suite_ids = draw.suites.available.where(size: size).map(&:id)
    passed_suite_ids = params[:suite_ids].map(&:to_i)
    Suite.find(current_suite_ids - passed_suite_ids)
  end

  def find_suites_to_add
    return [] unless params[:drawn_suite_ids] || params[:undrawn_suite_ids]
    Suite.find(params[:drawn_suite_ids] + params[:undrawn_suite_ids])
  end

  def remove_suites
    suites_to_remove.each { |suite| draw.suites.destroy(suite) }
  end

  def add_suites
    suites_to_add.each { |suite| draw.suites << suite }
  end

  def no_action_warning
    { object: nil, update_object: self, msg: { alert: 'No changes selected' } }
  end

  def success
    {
      object: nil, update_object: nil,
      msg: { success: 'Suites successfully updated' }
    }
  end

  def error(error)
    {
      object: nil, update_object: self,
      msg: { error: "Suites update failed: #{error}" }
    }
  end
end
