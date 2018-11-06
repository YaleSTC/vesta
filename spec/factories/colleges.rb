# frozen_string_literal: true

FactoryBot.define do
  factory :college do
    sequence(:name) { |n| "College#{n}" }
    admin_email { "admin@#{name}.edu" }
    subdomain { name.downcase }
    dean { "Dean #{name} " }
    allow_clipping true
    restrict_clipping_group_size false
    advantage_clips false
    size_sort { 'no_sort' }
  end
end
