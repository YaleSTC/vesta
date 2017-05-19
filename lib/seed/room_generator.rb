# frozen_string_literal: true

# Seed script generator for Rooms
class RoomGenerator
  include Callable

  def initialize(overrides: {})
    gen_params(overrides: overrides)
  end

  def generate
    RoomCreator.new(params).create![:redirect_object]
  end

  make_callable :generate

  private

  attr_reader :params

  def gen_params(overrides: {})
    @params ||= { suite: Suite.all.sample || SuiteGenerator.generate,
                  beds: rand(1..2),
                  number: FFaker::Address.building_number }.merge(overrides)
  end
end
