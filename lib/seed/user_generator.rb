# frozen_string_literal: true

# Seed script generator for Users
class UserGenerator
  include Callable

  def self.generate_superuser(**overrides)
    new(overrides: overrides.merge(role: 'superuser')).generate
  end

  def initialize(overrides: {})
    gen_params(overrides: overrides)
    @params.delete(:password) if User.cas_auth?
  end

  def generate
    Creator.new(klass: User, params: params,
                name_method: :name).create![:redirect_object]
  end

  make_callable :generate

  private

  attr_reader :params

  def gen_params(overrides: {})
    @params ||= { first_name: FFaker::Name.first_name,
                  last_name: FFaker::Name.last_name,
                  email: FFaker::Internet.email,
                  username: FFaker::Internet.user_name,
                  role: 'student',
                  intent: User.intents.keys.sample,
                  password: 'passw0rd',
                  class_year: random_class_year }.merge(overrides)
  end

  def random_class_year
    Time.zone.today.year + (1..3).to_a.sample
  end
end
