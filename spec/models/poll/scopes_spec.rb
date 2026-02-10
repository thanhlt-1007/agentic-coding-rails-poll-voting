require "rails_helper"

RSpec.describe Poll, type: :model do
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
end
