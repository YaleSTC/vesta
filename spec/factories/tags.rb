FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "Attribute#{n}" }
  end
end
