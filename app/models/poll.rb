class Poll < ApplicationRecord
  # Associations
  has_many :choices, dependent: :destroy
  has_many :votes, through: :choices
  accepts_nested_attributes_for :choices, reject_if: :all_blank, allow_destroy: true

  # Validations
  validates :question, presence: true, length: { maximum: 500 }
  validates :deadline, presence: true
  validates :access_code, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active closed] }
  validate :deadline_must_be_in_future, on: :create
  validate :minimum_two_choices, on: :create

  # Callbacks
  before_create :generate_access_code

  # Instance methods
  def active?
    status == 'active' && deadline > Time.current
  end

  def closed?
    status == 'closed' || deadline <= Time.current
  end

  def close!
    update!(status: 'closed')
  end

  private

  def generate_access_code
    self.access_code = SecureRandom.urlsafe_base64(6).upcase[0..7]
  end

  def deadline_must_be_in_future
    return unless deadline.present? && deadline <= Time.current
    
    errors.add(:deadline, "must be in the future")
  end

  def minimum_two_choices
    return unless choices.reject(&:marked_for_destruction?).size < 2
    
    errors.add(:base, "Poll must have at least 2 choices")
  end
end
