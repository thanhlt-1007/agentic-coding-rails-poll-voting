class Vote < ApplicationRecord
  # Associations
  belongs_to :poll, counter_cache: :total_votes
  belongs_to :choice, counter_cache: :votes_count

  # Validations
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
    return unless poll.present? && poll.status != 'active'
    
    errors.add(:base, "Poll is not active")
  end

  def deadline_not_passed
    return unless poll.present? && poll.deadline <= Time.current
    
    errors.add(:base, "Voting deadline has passed")
  end
end
