require "test_helper"

class VoteTest < ActiveSupport::TestCase
  setup do
    @poll = Poll.create!(
      question: "Test poll?",
      deadline: 1.day.from_now,
      choices_attributes: [
        { text: "Choice 1", position: 1 },
        { text: "Choice 2", position: 2 }
      ]
    )
    @choice = @poll.choices.first
  end

  test "should prevent duplicate votes from same participant" do
    fingerprint = "test-fingerprint-123"
    
    Vote.create!(
      poll: @poll,
      choice: @choice,
      participant_fingerprint: fingerprint,
      ip_hash: "ip-hash",
      voted_at: Time.current
    )

    duplicate_vote = Vote.new(
      poll: @poll,
      choice: @poll.choices.last,
      participant_fingerprint: fingerprint,
      ip_hash: "ip-hash",
      voted_at: Time.current
    )

    assert_not duplicate_vote.valid?
    assert_includes duplicate_vote.errors[:participant_fingerprint], "has already been taken"
  end

  test "should not allow voting on closed poll" do
    @poll.update!(status: 'closed')
    
    vote = Vote.new(
      poll: @poll,
      choice: @choice,
      participant_fingerprint: "fingerprint",
      ip_hash: "ip-hash",
      voted_at: Time.current
    )

    assert_not vote.valid?
    assert_includes vote.errors[:base], "Poll is not active"
  end

  test "should not allow voting after deadline" do
    poll = Poll.create!(
      question: "Test poll?",
      deadline: 2.hours.from_now,
      choices_attributes: [
        { text: "Choice 1" },
        { text: "Choice 2" }
      ]
    )
    
    travel_to 3.hours.from_now do
      vote = Vote.new(
        poll: poll,
        choice: poll.choices.first,
        participant_fingerprint: "fingerprint",
        ip_hash: "ip-hash",
        voted_at: Time.current
      )

      assert_not vote.valid?
      assert_includes vote.errors[:base], "Voting deadline has passed"
    end
  end

  test "should increment counter caches" do
    assert_difference ['@poll.reload.total_votes', '@choice.reload.votes_count'], 1 do
      Vote.create!(
        poll: @poll,
        choice: @choice,
        participant_fingerprint: "fingerprint",
        ip_hash: "ip-hash",
        voted_at: Time.current
      )
    end
  end

  test "should belong to poll" do
    vote = Vote.new(choice: @choice, participant_fingerprint: "fp", ip_hash: "ih")
    assert_not vote.valid?
    assert_includes vote.errors[:poll], "must exist"
  end

  test "should belong to choice" do
    vote = Vote.new(poll: @poll, participant_fingerprint: "fp", ip_hash: "ih")
    assert_not vote.valid?
    assert_includes vote.errors[:choice], "must exist"
  end
end
