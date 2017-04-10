# frozen_string_literal: true

# Seed script generator for Draws
class LotteryDrawGenerator
  def self.generate(**overrides)
    new(overrides: overrides).generate
  end

  def initialize(overrides: {}); end

  def generate
    create_draw_params
    make_lottery_draw
  end

  private

  def create_draw_params
    suites = Array.new(5) { SuiteGenerator.generate }
    suites.each { |s| RoomGenerator.generate(suite: s) }
    @params ||= { suites: suites,
                  name: "#{FFaker::Music.artist} Draw" }
  end

  def make_lottery_draw
    Draw.create!(params).tap do |d|
      d.update(status: 'pre_lottery')
      groups = Array.new(3) do
        GroupGenerator.generate(draw: d)
      end
      groups.each do |g|
        GroupLocker.lock(group: g)
      end
      DrawLotteryStarter.start(draw: d)
    end
  end

  attr_reader :params
end
