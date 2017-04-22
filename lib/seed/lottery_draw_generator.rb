# frozen_string_literal: true

# Seed script generator for Draws
class LotteryDrawGenerator
  def self.generate(**overrides)
    new(overrides: overrides).generate
  end

  def initialize(overrides: {});  end

  def generate(overrides: {})
    create_draw_params(overrides: overrides)
    make_lottery_draw(overrides: overrides)
  end

  private

  attr_reader :params

  def create_draw_params(overrides: {})
    suites = Array.new(5) { SuiteGenerator.generate }
    suites.each { |s| RoomGenerator.generate(suite: s) }
    @params ||= { suites: suites,
                  name: "#{FFaker::Music.artist} Draw" }.merge!(overrides)
  end

  def make_lottery_draw(overrides: {})
    Draw.create!(params).tap do |d|
      d.update(status: 'pre_lottery')
      groups = Array.new(3) do
        GroupGenerator.generate(draw: d, overrides: overrides)
      end
      groups.each do |g|
        GroupLocker.lock(group: g)
      end
      DrawLotteryStarter.start(draw: d)
    end
  end

end
