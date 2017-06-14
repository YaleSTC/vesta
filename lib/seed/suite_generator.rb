# frozen_string_literal: true

# Seed script generator for Suites
class SuiteGenerator
  include Callable

  def initialize(overrides: {})
    @overrides = overrides
  end

  def generate
    gen_params
    Creator.new(klass: Suite, params: params, name_method: :number)\
           .create![:record]
  end

  make_callable :generate

  private

  attr_reader :params, :overrides

  def gen_params
    @params ||= { building: Building.all.sample || BuildingGenerator.generate,
                  number: FFaker::Address.building_number }.merge(overrides)
  end
end
