# frozen_string_literal: true

FactoryBot.define do
  factory :college do
    sequence(:name) { |n| "College#{n}" }
    admin_email { "admin@#{name}.edu" }
    subdomain { name.downcase }
    dean { "Dean #{name} " }
  end
end
