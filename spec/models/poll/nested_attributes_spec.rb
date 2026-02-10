require "rails_helper"

RSpec.describe Poll, type: :model do
  describe "nested attributes" do
    it "creates poll with 4 answers via nested attributes" do
      user = create(:user)
      poll_params = {
        user: user,
        question: "Best color?",
        deadline: 1.week.from_now,
        answers_attributes: [
          { text: "Red", position: 1 },
          { text: "Blue", position: 2 },
          { text: "Green", position: 3 },
          { text: "Yellow", position: 4 }
        ]
      }
      poll = Poll.create!(poll_params)
      expect(poll.answers.count).to eq(4)
      expect(poll.answers.order(:position).map(&:text)).to eq([ "Red", "Blue", "Green", "Yellow" ])
    end
  end
end
