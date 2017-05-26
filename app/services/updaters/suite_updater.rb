# frozen_string_literal: true

# Service object to update Suites
class SuiteUpdater < Updater
  def initialize(suite:, params:)
    super(object: suite, params: params, name_method: :number)
  end

  private

  def success
    {
      redirect_object: [object.building, object], record: object,
      msg: { notice: "#{object.send(name_method)} updated." }
    }
  end
end
