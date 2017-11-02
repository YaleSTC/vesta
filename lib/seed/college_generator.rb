# frozen_string_literal: true

# Seed script generator for Colleges
class CollegeGenerator
  include Callable

  def initialize(overrides: {})
    gen_params(overrides: overrides)
  end

  def generate
    Creator.new(klass: College, params: params, name_method: :name)
           .create![:redirect_object]
  end

  make_callable :generate

  private

  attr_reader :params

  def gen_params(overrides: {})
    @params ||= {
      name: FFaker::Education.school_name,
      admin_email: FFaker::Internet.email,
      dean: FFaker::Name.name
    }.merge(overrides)
  end
end
