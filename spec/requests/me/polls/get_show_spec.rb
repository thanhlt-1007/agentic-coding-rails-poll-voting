# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /me/polls/:id', type: :request do
  let(:user) { create(:user) }
  let(:poll) { create(:poll, :with_answers, user: user) }

  describe 'when user is authenticated' do
    before { sign_in user, scope: :user }

    context 'when poll belongs to current user' do
      it 'returns http success' do
        get me_poll_path(poll)
        expect(response).to have_http_status(:success)
      end

      it 'displays the poll' do
        get me_poll_path(poll)
        expect(response.body).to include(poll.question)
      end
    end

    context 'when poll does not belong to current user' do
      let(:other_user) { create(:user) }
      let(:other_poll) { create(:poll, :with_answers, user: other_user) }

      it 'redirects to my polls page' do
        get me_poll_path(other_poll)
        expect(response).to redirect_to(me_polls_path)
      end

      it 'sets an alert flash message' do
        get me_poll_path(other_poll)
        follow_redirect!
        expect(response.body).to include('Poll not found')
      end
    end

    context 'when poll id does not exist' do
      it 'redirects to my polls page' do
        get me_poll_path(id: 99999)
        expect(response).to redirect_to(me_polls_path)
      end

      it 'sets an alert flash message' do
        get me_poll_path(id: 99999)
        follow_redirect!
        expect(response.body).to include('Poll not found')
      end
    end
  end

  describe 'when user is not authenticated' do
    it 'redirects to login page' do
      get me_poll_path(poll)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
