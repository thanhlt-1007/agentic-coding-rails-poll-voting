require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = Poll.create!(
      question: "What's your favorite color?",
      deadline: 1.day.from_now,
      choices_attributes: [
        { text: "Red", position: 1 },
        { text: "Blue", position: 2 },
        { text: "Green", position: 3 }
      ]
    )
    @choice = @poll.choices.first
  end

  test "should create vote with valid params" do
    assert_difference('Vote.count') do
      post poll_votes_url(@poll.access_code), params: {
        vote: {
          choice_id: @choice.id
        }
      }
    end

    assert_redirected_to poll_url(@poll.access_code)
    assert_equal "Thank you for voting!", flash[:notice]
  end

  test "should prevent duplicate vote" do
    # First vote
    post poll_votes_url(@poll.access_code), params: {
      vote: { choice_id: @choice.id }
    }

    # Second vote attempt (duplicate)
    assert_no_difference('Vote.count') do
      post poll_votes_url(@poll.access_code), params: {
        vote: { choice_id: @poll.choices.last.id }
      }
    end

    assert_redirected_to poll_url(@poll.access_code)
    assert_equal "You have already voted on this poll", flash[:alert]
  end

  test "should redirect after vote" do
    post poll_votes_url(@poll.access_code), params: {
      vote: { choice_id: @choice.id }
    }

    assert_redirected_to poll_url(@poll.access_code)
  end

  test "should show error for closed poll" do
    @poll.update!(status: 'closed')

    assert_no_difference('Vote.count') do
      post poll_votes_url(@poll.access_code), params: {
        vote: { choice_id: @choice.id }
      }
    end

    assert_redirected_to poll_url(@poll.access_code)
    assert_equal "Poll is not active", flash[:alert]
  end
end
