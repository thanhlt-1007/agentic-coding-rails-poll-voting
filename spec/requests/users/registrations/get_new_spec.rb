# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Registrations', type: :request do
  describe 'GET /users/sign_up' do
    it 'returns success response' do
      get new_user_registration_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the sign up form' do
      get new_user_registration_path
      expect(response.body).to include('Sign up')
      expect(response.body).to include('Email')
      expect(response.body).to include('Password')
    end

    context 'when user is already signed in' do
      let(:user) { create(:user) }

      before { sign_in user, scope: :user }

      it 'redirects to root path' do
        get new_user_registration_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
