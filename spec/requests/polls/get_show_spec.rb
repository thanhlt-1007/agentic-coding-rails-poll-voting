# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /polls/:id', type: :request do
  describe 'show action' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user1_poll) { create(:poll, :with_answers, user: user1, question: "User 1 Poll?") }
    let(:user2_poll) { create(:poll, :with_answers, user: user2, question: "User 2 Poll?") }

    before { sign_in user1, scope: :user }

    context 'when viewing other user\'s poll' do
      it 'returns http success' do
        get poll_path(user2_poll)
        expect(response).to have_http_status(:success)
      end

      it 'displays the poll question' do
        get poll_path(user2_poll)
        expect(response.body).to include("User 2 Poll?")
      end
    end

    context 'when trying to view own poll' do
      it 'redirects to polls index' do
        get poll_path(user1_poll)
        expect(response).to redirect_to(polls_path)
      end

      it 'shows error message' do
        get poll_path(user1_poll)
        follow_redirect!
        expect(response.body).to include("Poll not found")
      end
    end

    context 'when poll does not exist' do
      it 'redirects to polls index' do
        get poll_path(id: 99999)
        expect(response).to redirect_to(polls_path)
      end

      it 'shows error message' do
        get poll_path(id: 99999)
        follow_redirect!
        expect(response.body).to include("Poll not found")
      end
    end
  end
end
