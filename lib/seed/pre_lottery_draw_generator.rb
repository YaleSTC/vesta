# frozen_string_literal: true

# Seed script generator for Draws
class PreLotteryDrawGenerator
  def self.generate(**overrides)
    new(overrides: overrides).generate
  end

  def initialize(overrides: {});  end

  def generate(overrides: {})
    DrawGenerator.generate(overrides: overrides).tap do |d|
      3.times { GroupGenerator.generate(draw: d, overrides: overrides) }
      d.update(status: 'pre_lottery')
    end
  end

end
