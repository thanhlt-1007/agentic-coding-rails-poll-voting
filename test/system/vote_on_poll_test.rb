require "application_system_test_case"

class VoteOnPollTest < ApplicationSystemTestCase
  setup do
    @poll = Poll.create!(
      question: "What's your favorite programming language?",
      deadline: 1.day.from_now,
      choices_attributes: [
        { text: "Ruby", position: 1 },
        { text: "Python", position: 2 },
        { text: "JavaScript", position: 3 }
      ]
    )
  end

  test "voting on active poll" do
    visit poll_url(@poll.access_code)

    assert_text "What's your favorite programming language?"
    
    choose "Ruby"
    click_button "Submit Vote"

    assert_text "Thank you for voting!"
  end

  test "cannot vote twice on same poll" do
    visit poll_url(@poll.access_code)

    choose "Ruby"
    click_button "Submit Vote"

    assert_text "Thank you for voting!"
    
    # Refresh page to verify duplicate vote prevention
    visit poll_url(@poll.access_code)
    assert_text "You have already voted on this poll"
  end

  test "shows closed message after deadline" do
    poll = Poll.create!(
      question: "Test poll?",
      deadline: 2.hours.from_now,
      choices_attributes: [
        { text: "Choice 1" },
        { text: "Choice 2" }
      ]
    )

    travel_to 3.hours.from_now do
      visit poll_url(poll.access_code)
      assert_text "This poll is closed"
    end
  end
end
