# frozen_string_literal: true

# Seed script generator for Suites
class SuiteGenerator
  include Callable

  def initialize(overrides: {})
    gen_params(overrides: overrides)
  end

  def generate
    SuiteCreator.new(params).create![:record]
  end

  make_callable :generate

  private

  attr_reader :params

  def gen_params(overrides: {})
    @params ||= { building: Building.all.sample || BuildingGenerator.generate,
                  number: FFaker::Address.building_number }.merge(overrides)
  end
end
