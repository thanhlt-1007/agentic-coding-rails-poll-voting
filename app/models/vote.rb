class Vote < ApplicationRecord
  # Associations
  belongs_to :poll, counter_cache: :total_votes
  belongs_to :choice, counter_cache: :votes_count

  # Validations
  validates :poll_id, presence: true
  validates :choice_id, presence: true
  validates :participant_fingerprint, presence: true, uniqueness: { scope: :poll_id }
  validates :voted_at, presence: true
  validate :poll_must_be_active
  validate :deadline_not_passed

  # Callbacks
  before_validation :set_voted_at

  # Instance methods
  private

  def set_voted_at
    self.voted_at ||= Time.current
  end

  def poll_must_be_active
    return unless poll.present? && !poll.active?
    
    errors.add(:poll, "must be active")
  end

  def deadline_not_passed
    return unless poll.present? && poll.deadline <= Time.current
    
    errors.add(:base, "Poll has closed")
  end
end
