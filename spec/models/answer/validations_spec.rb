# frozen_string_literal: true

require "rails_helper"

RSpec.describe Answer do
  describe "validations" do
    it { should validate_presence_of(:text) }
    it { should validate_length_of(:text).is_at_most(255) }
    it { should validate_presence_of(:position) }

    it "validates numericality of position" do
      answer = build(:answer, position: "invalid")
      expect(answer).not_to be_valid
      expect(answer.errors[:position]).to include("is not a number")
    end

    it "validates position is greater than 0" do
      answer = build(:answer, position: 0)
      expect(answer).not_to be_valid
      expect(answer.errors[:position]).to include("must be greater than 0")
    end

    it "validates position is less than or equal to 4" do
      answer = build(:answer, position: 5)
      expect(answer).not_to be_valid
      expect(answer.errors[:position]).to include("must be less than or equal to 4")
    end

    context "uniqueness validation" do
      let(:poll) { create(:poll, :with_answers) }
      let(:existing_answer) { poll.answers.first }

      it "validates uniqueness of position scoped to poll_id" do
        duplicate_position = build(:answer, poll: poll, position: existing_answer.position)
        expect(duplicate_position).not_to be_valid
        expect(duplicate_position.errors[:position]).to include("has already been taken")
      end

      it "allows same position in different polls" do
        # Get position from existing answer in first poll
        position_value = existing_answer.position

        # Create second poll with answers (will have positions 1-4)
        second_poll = create(:poll, :with_answers)

        # The second poll should also have an answer at the same position
        second_poll_answer = second_poll.answers.find_by(position: position_value)
        expect(second_poll_answer).to be_present

        # Both answers have same position but different polls - both are valid
        expect(existing_answer).to be_valid
        expect(second_poll_answer).to be_valid
      end
    end
  end
end
