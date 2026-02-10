# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  describe "associations" do
    it { should have_many(:polls).dependent(:destroy) }
  end
end
