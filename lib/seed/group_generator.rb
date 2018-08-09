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
    # Use Generator to ensure we don't get invalid members due to validations
    members = Generator.generate(model: 'user', count: size)
    draw_memberships = members.map do |m|
      DrawMembership.create!(user: m, draw: draw,
                             active: true, intent: 'on_campus')
    end
    @params ||= { leader_draw_membership: draw_memberships.sample,
                  size: size,
                  draw_memberships: draw_memberships,
                  draw: draw }.merge!(overrides)
  end
end
