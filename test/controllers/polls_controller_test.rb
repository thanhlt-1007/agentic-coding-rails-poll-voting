require "test_helper"

class PollsControllerTest < ActionDispatch::IntegrationTest
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
  end

  test "should get new" do
    get new_poll_url
    assert_response :success
  end

  test "should create poll with valid params" do
    assert_difference('Poll.count') do
      post polls_url, params: {
        poll: {
          question: "What's for lunch?",
          deadline: 1.day.from_now,
          show_results_while_voting: true,
          choices_attributes: {
            "0" => { text: "Pizza", position: 1 },
            "1" => { text: "Sushi", position: 2 }
          }
        }
      }
    end

    assert_redirected_to poll_url(Poll.last.access_code)
  end

  test "should not create poll with invalid params" do
    assert_no_difference('Poll.count') do
      post polls_url, params: {
        poll: {
          question: "",
          deadline: 1.day.from_now
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show poll" do
    get poll_url(@poll.access_code)
    assert_response :success
  end
end
