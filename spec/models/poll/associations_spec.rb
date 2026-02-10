require "rails_helper"

RSpec.describe Poll, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:answers).dependent(:destroy) }
    it { should accept_nested_attributes_for(:answers) }
  end
end
