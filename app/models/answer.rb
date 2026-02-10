# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :poll
  has_many :user_answers, dependent: :destroy

  validates :text, presence: true, length: { maximum: 255 }
  validates :position, presence: true,
                       numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 4 },
                       uniqueness: { scope: :poll_id }

  def to_s
    text
  end
end
