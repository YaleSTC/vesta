# frozen_string_literal: true
FactoryGirl.define do
  factory :college do
    sequence(:name) { |n| "College#{n}" }
    admin_email { "admin@#{name}.edu" }
    site_url { 'https://www.vesta.site' }
    dean { "Dean #{name} " }
  end
end
