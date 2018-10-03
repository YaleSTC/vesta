# frozen_string_literal: true

# Seed script generator for Suites
class SuiteGenerator
  include Callable

  def initialize(overrides: {}, room_count: rand(1..3))
    @overrides = overrides
    @room_count = room_count
  end

  def generate
    gen_params
    suite = Creator.new(klass: Suite, params: params, name_method: :number)\
                   .create![:record]
    gen_rooms_in(suite)
    suite
  end

  make_callable :generate

  private

  attr_reader :params, :overrides, :room_count

  def gen_params
    @params ||= { building: Building.all.sample || BuildingGenerator.generate,
                  number: FFaker::Address.building_number }.merge(overrides)
  end

  def gen_rooms_in(suite)
    room_count.times { RoomGenerator.generate(overrides: { suite: suite }) }
    (room_count % 2).times do
      RoomGenerator.generate(overrides: { suite: suite, beds: 0 })
    end
  end
end
