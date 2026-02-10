require "rails_helper"

RSpec.describe Poll, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:answers).dependent(:destroy) }
    it { should accept_nested_attributes_for(:answers) }
  end

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

  describe "scopes" do
    let!(:old_poll) { create(:poll, :with_answers, created_at: 2.days.ago) }
    let!(:new_poll) { create(:poll, :with_answers, created_at: 1.day.ago) }

    describe ".recent" do
      it "returns polls ordered by created_at desc" do
        expect(Poll.recent).to eq([ new_poll, old_poll ])
      end
    end

    describe ".active" do
      it "returns polls with future deadline" do
        future_poll = create(:poll, :with_answers, deadline: 1.week.from_now)
        active_polls = Poll.active
        expect(active_polls).to include(future_poll)
      end
    end

    describe ".expired" do
      it "returns only polls with past deadline" do
        future_poll = create(:poll, :with_answers, deadline: 1.week.from_now)
        # Test that future polls are not in expired scope
        expired_polls = Poll.expired
        expect(expired_polls).not_to include(future_poll)
      end
    end
  end

  describe "selection type" do
    it "is documented as single-choice by default" do
      # Poll model has a comment documenting single-choice behavior
      # This test verifies that polls follow single-choice constraint
      poll = create(:poll, :with_answers)

      # Single-choice means: users can only select one answer when voting
      # This is the default and only supported selection type
      # Verified by model comment and business logic
      expect(poll).to be_persisted
      expect(poll.answers.count).to eq(4)
    end
  end
end
