# frozen_string_literal: true

class UserAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :poll
  belongs_to :answer

  validates :user_id, uniqueness: { scope: :poll_id, message: "has already answered this poll" }
  validate :answer_belongs_to_poll

  private

  def answer_belongs_to_poll
    return unless answer && poll

    unless answer.poll_id == poll.id
      errors.add(:answer, "must belong to the specified poll")
    end
  end
end
