class Poll < ApplicationRecord
  # Selection Type: Single-choice
  # All polls are single-choice (radio button behavior).
  # Users can only select one answer when voting.
  # This is the default and only supported selection type.

  # Associations
  belongs_to :user
  has_many :answers, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :answers, reject_if: :all_blank, allow_destroy: false

  # Validations
  validates :question, presence: true, length: { minimum: 5, maximum: 500 }
  validates :answers, length: { is: 4, message: "must have exactly 4 options" }
  validates :user, presence: true
  validates :deadline, presence: true

  validate :answers_must_be_unique
  validate :deadline_must_be_in_future

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where("deadline > ?", Time.current) }
  scope :expired, -> { where("deadline <= ?", Time.current) }

  private

  def answers_must_be_unique
    return if answers.empty?

    answer_texts = answers.map { |a| a.text.to_s.downcase.strip }.reject(&:blank?)
    duplicates = answer_texts.select { |text| answer_texts.count(text) > 1 }.uniq

    if duplicates.any?
      errors.add(:base, "Answer options must be unique")
    end
  end

  def deadline_must_be_in_future
    if deadline.present? && deadline <= Time.current
      errors.add(:deadline, "must be in the future")
    end
  end
end
