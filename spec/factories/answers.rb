FactoryBot.define do
  factory :answer do
    association :poll
    sequence(:text) { |n| "Answer option #{n}" }
    sequence(:position) { |n| n }
  end
end
