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

    context "with filter parameter" do
      let!(:active_poll) { create(:poll, :with_answers, user: user, question: "Active Poll?", deadline: 2.days.from_now) }
      let!(:expired_poll) do
        poll = build(:poll, :with_answers, user: user, question: "Expired Poll?", deadline: 2.days.ago)
        poll.save(validate: false)
        poll
      end

      it "filters by all polls by default" do
        get me_polls_path
        expect(response.body).to include("Active Poll?")
        expect(response.body).to include("Expired Poll?")
      end

      it "filters by active polls" do
        get me_polls_path(filter: 'active')
        expect(response.body).to include("Active Poll?")
        expect(response.body).not_to include("Expired Poll?")
      end

      it "filters by expired polls" do
        get me_polls_path(filter: 'expired')
        expect(response.body).to include("Expired Poll?")
        expect(response.body).not_to include("Active Poll?")
      end

      it "shows all polls when filter is 'all'" do
        get me_polls_path(filter: 'all')
        expect(response.body).to include("Active Poll?")
        expect(response.body).to include("Expired Poll?")
      end

      it "displays filter tabs" do
        get me_polls_path
        expect(response.body).to include("All")
        expect(response.body).to include("Active")
        expect(response.body).to include("Expired")
      end
    end
  end

  describe "when user is not authenticated" do
    it "redirects to login page" do
      get me_polls_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
