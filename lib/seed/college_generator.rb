# frozen_string_literal: true
# Seed script generator for Colleges
class CollegeGenerator
  def self.generate(**overrides)
    new(overrides: overrides).generate
  end

  def initialize(overrides: {})
    gen_params(overrides: overrides)
  end

  def generate
    Creator.new(klass: College, params: params, name_method: :name)
           .create![:object]
  end

  private

  attr_reader :params

  def gen_params(overrides: {})
    @params ||= {
      name: FFaker::Education.school_name,
      admin_email: FFaker::Internet.email,
      dean: FFaker::Name.name,
      site_url: FFaker::Internet.http_url
    }.merge(overrides)
  end
end
