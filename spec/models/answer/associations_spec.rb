# frozen_string_literal: true

require "rails_helper"

RSpec.describe Answer do
  describe "associations" do
    it { should belong_to(:poll) }
  end
end
