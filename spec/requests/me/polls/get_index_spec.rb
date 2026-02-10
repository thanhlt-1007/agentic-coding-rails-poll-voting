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

    context "with pagination" do
      before do
        # Create 15 polls to test pagination (12 per page)
        15.times do |i|
          poll = build(:poll, :with_answers, user: user, question: "Poll #{i + 1}?", deadline: 2.days.from_now)
          poll.save(validate: false)
        end
      end

      it "displays first page of polls" do
        get me_polls_path
        # Most recent polls (15, 14, 13... down to 4) on first page
        expect(response.body).to include("Poll 15?")
        expect(response.body).to include("Poll 4?")
        expect(response.body).not_to include("Poll 3?")
      end

      it "displays second page of polls" do
        get me_polls_path(page: 2)
        # Older polls (3, 2, 1) on second page
        expect(response.body).to include("Poll 3?")
        expect(response.body).to include("Poll 1?")
        expect(response.body).not_to include("Poll 4?")
      end

      it "displays pagination navigation when polls exceed page limit" do
        get me_polls_path
        expect(response.body).to match(/page=2/)
      end
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

    context "with filter and pagination combined" do
      before do
        # Create 15 active polls and 10 expired polls
        15.times do |i|
          poll = build(:poll, :with_answers, user: user, question: "Active Poll #{i + 1}?", deadline: 2.days.from_now)
          poll.save(validate: false)
        end
        
        10.times do |i|
          poll = build(:poll, :with_answers, user: user, question: "Expired Poll #{i + 1}?", deadline: 2.days.ago)
          poll.save(validate: false)
        end
      end

      it "paginates active polls correctly" do
        get me_polls_path(filter: 'active')
        # Should show first 12 active polls
        expect(response.body).to include("Active Poll 15?")
        expect(response.body).to include("Active Poll 4?")
        expect(response.body).not_to include("Active Poll 3?")
        expect(response.body).not_to include("Expired Poll")
      end

      it "preserves filter parameter in pagination links for active filter" do
        get me_polls_path(filter: 'active')
        expect(response.body).to match(/filter=active/)
        expect(response.body).to match(/page=2.*filter=active|filter=active.*page=2/)
      end

      it "paginates expired polls correctly" do
        get me_polls_path(filter: 'expired', page: 1)
        # Should show first 10 expired polls (all fit on one page)
        expect(response.body).to include("Expired Poll 10?")
        expect(response.body).to include("Expired Poll 1?")
        expect(response.body).not_to include("Active Poll")
      end

      it "shows second page of active polls with filter preserved" do
        get me_polls_path(filter: 'active', page: 2)
        # Second page should show remaining 3 active polls
        expect(response.body).to include("Active Poll 3?")
        expect(response.body).to include("Active Poll 1?")
        expect(response.body).not_to include("Active Poll 4?")
        expect(response.body).not_to include("Expired Poll")
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
