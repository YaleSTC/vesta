# frozen_string_literal: true

# Base class for all draw generators
class DrawGenerator
  include Callable

  def initialize(overrides: {}, group_overrides: {}, group_count: rand(3..7))
    @overrides = overrides
    @group_overrides = group_overrides
    @group_count = group_count
  end

  def generate
    create_draw
    add_members
    update_status
    draw
  end

  make_callable :generate

  private

  attr_reader :params, :suites, :overrides,
              :group_overrides, :group_count, :draw

  def create_draw
    @draw ||= Draw.create!(gen_params)
  end

  def gen_params
    add_suites
    @params ||= { suites: suites,
                  name: "#{FFaker::Music.artist} Draw" }.merge!(overrides)
  end

  def add_suites
    @suites ||= Array.new(group_count + 1) do
      SuiteGenerator.generate.tap do |s|
        rand(1..3).times { RoomGenerator.generate(overrides: { suite: s }) }
      end
    end
  end

  def add_members
    group_count.times do
      GroupGenerator.generate(draw: draw, overrides: group_overrides)
    end
  end

  def update_status
    draw.update(status: status)
  end

  def status
    'draft'
  end
end
