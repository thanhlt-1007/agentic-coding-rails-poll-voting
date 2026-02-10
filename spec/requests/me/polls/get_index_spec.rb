require "rails_helper"

RSpec.describe "GET /me/polls", type: :request do
  let(:user) { create(:user) }

  describe "when user is authenticated" do
    before { sign_in user, scope: :user }

    it "returns http success" do
      get me_polls_path
      expect(response).to have_http_status(:success)
    end

    it "displays the user's polls" do
      poll = create(:poll, :with_answers, user: user, question: "Test Poll?")
      get me_polls_path
      expect(response.body).to include("Test Poll?")
    end
  end

  describe "when user is not authenticated" do
    it "redirects to login page" do
      get me_polls_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
