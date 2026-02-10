class Choice < ApplicationRecord
  # Associations
  belongs_to :poll
  has_many :votes, dependent: :destroy

  # Validations
  validates :text, presence: true, length: { maximum: 200 }

  # Counter cache callbacks
  after_create :update_poll_total_votes
  after_destroy :update_poll_total_votes

  # Instance methods
  def percentage
    return 0 if poll.total_votes.zero?
    
    (votes_count.to_f / poll.total_votes * 100).round(1)
  end

  private

  def update_poll_total_votes
    poll.update(total_votes: poll.choices.sum(:votes_count))
  end
end
