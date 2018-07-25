# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    sequence(:number, &:to_s)
    suite

    factory :single do
      beds 1
    end
    factory :double do
      beds 2
    end
  end
end
