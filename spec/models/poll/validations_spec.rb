require "rails_helper"

RSpec.describe Poll, type: :model do
  describe "validations" do
    it { should validate_presence_of(:question) }
    it { should validate_length_of(:question).is_at_least(5).is_at_most(500) }

    describe "answers count validation" do
      it "requires exactly 4 answers" do
        poll = build(:poll, answers_attributes: [
          { text: "A", position: 1 },
          { text: "B", position: 2 },
          { text: "C", position: 3 }
        ])
        expect(poll).not_to be_valid
        expect(poll.errors[:answers]).to include(match(/exactly 4/))
      end

      it "accepts exactly 4 answers" do
        poll = build(:poll, answers_attributes: [
          { text: "A", position: 1 },
          { text: "B", position: 2 },
          { text: "C", position: 3 },
          { text: "D", position: 4 }
        ])
        expect(poll).to be_valid
      end
    end

    describe "answer uniqueness validation" do
      it "rejects duplicate answers (case-insensitive)" do
        poll = build(:poll, answers_attributes: [
          { text: "Same", position: 1 },
          { text: "same", position: 2 },
          { text: "C", position: 3 },
          { text: "D", position: 4 }
        ])
        expect(poll).not_to be_valid
        expect(poll.errors[:base]).to include(match(/unique/i))
      end

      it "accepts unique answers" do
        poll = build(:poll, answers_attributes: [
          { text: "A", position: 1 },
          { text: "B", position: 2 },
          { text: "C", position: 3 },
          { text: "D", position: 4 }
        ])
        expect(poll).to be_valid
      end
    end

    describe "deadline validation" do
      it { should validate_presence_of(:deadline) }

      it "accepts future deadline" do
        poll = build(:poll, :with_answers, deadline: 1.week.from_now)
        expect(poll).to be_valid
      end

      it "rejects past deadline" do
        poll = build(:poll, :with_answers, deadline: 1.day.ago)
        expect(poll).not_to be_valid
        expect(poll.errors[:deadline]).to include(match(/future/i))
      end

      it "rejects deadline at current time" do
        poll = build(:poll, :with_answers, deadline: Time.current)
        expect(poll).not_to be_valid
      end
    end
  end
end
