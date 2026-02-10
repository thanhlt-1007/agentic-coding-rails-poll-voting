# frozen_string_literal: true

FactoryBot.define do
  factory :user_answer do
    user
    poll
    answer

    trait :with_valid_answer do
      after(:build) do |user_answer|
        user_answer.poll ||= create(:poll, :with_answers)
        user_answer.answer ||= user_answer.poll.answers.first
      end
    end
  end
end
