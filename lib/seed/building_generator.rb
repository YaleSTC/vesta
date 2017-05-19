# frozen_string_literal: true

# Seed script generator for Buildings
class BuildingGenerator
  include Callable

  def initialize(overrides: {})
    gen_params(overrides: overrides)
  end

  def generate
    Creator.create!(params: params, klass: Building,
                    name_method: :name)[:redirect_object]
  end

  make_callable :generate

  private

  attr_reader :params

  def gen_params(overrides: {})
    @params ||= { name: FFaker::Education.school_name }.merge(overrides)
  end
end
