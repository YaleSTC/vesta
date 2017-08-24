# frozen_string_literal: true

# Seed script generator for Suites
class GroupGenerator
  def self.generate(**params)
    new(**params).generate
  end

  def initialize(draw:, overrides: {})
    gen_params(draw: draw, overrides: overrides)
  end

  def generate
    Group.create!(params)
  end

  private

  attr_reader :params

  def gen_params(draw:, overrides: {})
    size = draw.suite_sizes.sample
    members = Array.new(size) do |_d|
      UserGenerator.generate(draw: draw, intent: 'on_campus')
    end
    @params ||= { leader: members.sample,
                  size: size,
                  members: members,
                  draw: draw }.merge!(overrides)
  end
end
