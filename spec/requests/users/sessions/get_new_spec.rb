# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Sessions', type: :request do
  let(:user) { create(:user, email: 'user@example.com', password: 'password123') }

  describe 'GET /users/sign_in' do
    it 'returns success response' do
      get new_user_session_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the sign in form' do
      get new_user_session_path
      expect(response.body).to include('Log in')
      expect(response.body).to include('Email')
      expect(response.body).to include('Password')
    end

    it 'includes sign up link' do
      get new_user_session_path
      expect(response.body).to include('Sign up')
      expect(response.body).to include(new_user_registration_path)
    end

    context 'when user is already signed in' do
      before { sign_in user, scope: :user }

      it 'redirects to root path' do
        get new_user_session_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
