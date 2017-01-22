# frozen_string_literal: true
# Seed script generator for Buildings
class BuildingGenerator
  def self.generate(**overrides)
    new(overrides: overrides).generate
  end

  def initialize(overrides: {})
    gen_params(overrides: overrides)
  end

  def generate
    BuildingCreator.new(params).create![:object]
  end

  private

  attr_reader :params

  def gen_params(overrides: {})
    @params ||= { name: FFaker::Education.school_name }.merge(overrides)
  end
end
