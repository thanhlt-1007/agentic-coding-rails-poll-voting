require "test_helper"

class ChoiceTest < ActiveSupport::TestCase
  setup do
    @poll = Poll.create!(
      question: "Test?",
      deadline: 1.day.from_now,
      choices_attributes: [{ text: "Choice 1" }, { text: "Choice 2" }]
    )
    @choice = @poll.choices.first
  end

  test "should belong to poll" do
    assert_respond_to @choice, :poll
    assert_equal @poll, @choice.poll
  end

  test "should validate text presence" do
    choice = Choice.new(poll: @poll)
    assert_not choice.save
    assert_includes choice.errors[:text], "can't be blank"
  end

  test "should validate text length maximum 200" do
    choice = Choice.new(poll: @poll, text: "a" * 201)
    assert_not choice.save
    assert_includes choice.errors[:text], "is too long (maximum is 200 characters)"
  end

  test "should calculate percentage correctly" do
    @poll.update(total_votes: 100)
    @choice.update(votes_count: 45)
    assert_equal 45.0, @choice.percentage
  end

  test "should return zero percentage when poll has no votes" do
    assert_equal 0, @choice.percentage
  end
end
