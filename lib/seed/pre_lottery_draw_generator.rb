# frozen_string_literal: true

# Seed script generator for Draws
class PreLotteryDrawGenerator
  def self.generate(**overrides)
    new(overrides: overrides).generate
  end

  def initialize(overrides: {}); end

  def generate
    DrawGenerator.generate.tap do |d|
      3.times { GroupGenerator.generate(draw: d) }
      d.update(status: 'pre_lottery')
    end
  end

  private

  attr_reader :params
end
