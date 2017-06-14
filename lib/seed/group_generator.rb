# frozen_string_literal: true

# Seed script generator for groups in a draw
class GroupGenerator
  def self.generate(**params)
    new(**params).generate
  end

  def initialize(draw:, overrides: {})
    @overrides = overrides
    @draw = draw
  end

  def generate
    gen_params
    Group.create!(params)
  end

  private

  attr_reader :params, :overrides, :draw

  def gen_params
    size = draw.suite_sizes.sample
    members = Array.new(size) do
      UserGenerator.generate(overrides: { draw: draw, intent: 'on_campus' })
    end
    @params ||= { leader: members.sample,
                  size: size,
                  members: members,
                  draw: draw }.merge!(overrides)
  end
end
