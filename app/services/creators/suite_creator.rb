# frozen_string_literal: true

#
# Service object to create Suites.
class SuiteCreator < Creator
  # Initialize a new SuiteCreator
  #
  # @param [ActionController::Parameters] params The params object from
  #   the SuitesController.
  def initialize(params)
    super(klass: Suite, name_method: :number, params: params)
  end

  private

  def success
    {
      redirect_object: [obj.building, obj],
      record: obj,
      msg: { success: "#{obj.send(name_method)} created." }
    }
  end
end
