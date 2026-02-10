# frozen_string_literal: true

require "rails_helper"

RSpec.describe Answer do
  describe "#to_s" do
    it "returns the text attribute" do
      answer = build(:answer, text: "Sample answer")
      expect(answer.to_s).to eq("Sample answer")
    end
  end
end
