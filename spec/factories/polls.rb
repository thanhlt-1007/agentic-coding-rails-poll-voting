FactoryBot.define do
  factory :poll do
    association :user
    question { "What is your favorite programming language?" }
    deadline { 1.week.from_now }

    trait :expired do
      deadline { 1.day.ago }
    end

    trait :with_answers do
      after(:build) do |poll|
        4.times do |i|
          poll.answers.build(text: "Answer #{i + 1}", position: i + 1)
        end
      end
    end
  end
end
