require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "should not save poll without question" do
    poll = Poll.new(deadline: 1.day.from_now)
    assert_not poll.save, "Saved poll without question"
  end

  test "should not save poll with past deadline" do
    poll = Poll.new(question: "Test?", deadline: 1.day.ago)
    assert_not poll.save, "Saved poll with past deadline"
  end

  test "should generate unique access code on create" do
    poll = Poll.new(question: "Test?", deadline: 1.day.from_now)
    poll.choices.build(text: "Choice 1")
    poll.choices.build(text: "Choice 2")
    assert poll.save
    assert_not_nil poll.access_code
    assert_equal 8, poll.access_code.length
  end

  test "should require minimum 2 choices" do
    poll = Poll.new(question: "Test?", deadline: 1.day.from_now)
    poll.choices.build(text: "Only one")
    assert_not poll.save, "Saved poll with only 1 choice"
  end

  test "active? should return true for active poll before deadline" do
    poll = Poll.create!(
      question: "Test?",
      deadline: 1.day.from_now,
      status: 'active',
      choices_attributes: [{ text: "Choice 1" }, { text: "Choice 2" }]
    )
    assert poll.active?
  end

  test "closed? should return true after deadline" do
    poll = Poll.create!(
      question: "Test?",
      deadline: 2.hours.from_now,
      choices_attributes: [{ text: "Choice 1" }, { text: "Choice 2" }]
    )
    
    travel_to 3.hours.from_now do
      assert poll.closed?
    end
  end

  test "should accept nested attributes for choices" do
    poll = Poll.create!(
      question: "Test?",
      deadline: 1.day.from_now,
      choices_attributes: [
        { text: "Choice 1", position: 1 },
        { text: "Choice 2", position: 2 }
      ]
    )
    assert_equal 2, poll.choices.count
  end
end
