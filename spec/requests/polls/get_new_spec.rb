# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /polls/new" do
  context "when user is authenticated" do
    let(:user) { create(:user) }

    before do
      sign_in user, scope: :user
    end

    it "returns http success" do
      get new_poll_path
      expect(response).to have_http_status(:success)
    end

    it "includes the poll form in the response" do
      get new_poll_path
      expect(response.body).to include("Create a New Poll")
      expect(response.body).to include("Question")
      expect(response.body).to include("Answer Options")
    end
  end

  context "when user is not authenticated" do
    it "redirects to login page" do
      get new_poll_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
