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
    DrawCreator.new(params).create![:object]
  end

  private

  attr_reader :params

  def gen_params(overrides: {})
    check_member_existence
    @params ||= { suites: Suite.all.sample(3),
                  students: User.where(role: 'student', draw_id: nil).sample(5),
                  name: "#{FFaker::Music.artist} Draw" }.merge(overrides)
  end

  def check_member_existence
    5.times { SuiteGenerator.generate } unless Suite.all.count >= 5
    8.times { UserGenerator.generate } unless User.all.count >= 8
  end
end
