# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Registrations', type: :request do
  describe 'GET /users/edit' do
    let(:user) { create(:user) }

    context 'when user is signed in' do
      before do
        post user_session_path, params: { user: { email: user.email, password: user.password } }
      end

      it 'returns success response' do
        get edit_user_registration_path
        expect(response).to have_http_status(:success)
      end

      it 'displays the edit form' do
        get edit_user_registration_path
        expect(response.body).to include('Edit User')
        expect(response.body).to include(user.email)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        get edit_user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
