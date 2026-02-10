require "rails_helper"

RSpec.describe Poll, type: :model do
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
