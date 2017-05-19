# frozen_string_literal: true

# Seed script generator for Draws
class DrawGenerator
  include Callable

  def initialize(overrides: {})
    gen_params(overrides: overrides)
  end

  def generate
    Creator.create!(params: params, klass: Draw, name_method: :name)[:object]
  end

  make_callable :generate

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
