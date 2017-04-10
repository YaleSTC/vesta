# frozen_string_literal: true

# Seed script generator for Draws
class DrawGenerator
  def self.generate(**overrides)
    new(overrides: overrides).generate
  end

  def initialize(overrides: {})
    gen_params(overrides: overrides)
  end

  def generate
    Draw.create(params)
  end

  private

  attr_reader :params, :suites

  def gen_params(overrides: {})
    check_member_existence
    @params ||= { suites: suites,
                  name: "#{FFaker::Music.artist} Draw" }.merge(overrides)
  end

  def check_member_existence
    @suites = Array.new(5) { SuiteGenerator.generate }
    suites.each { |s| RoomGenerator.generate(suite: s) }
    8.times { UserGenerator.generate } unless User.all.count >= 8
  end
end
