# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Registrations', type: :request do
  describe 'PATCH /users' do
    let(:user) { create(:user, email: 'original@example.com') }

    context 'when user is signed in' do
      before do
        post user_session_path, params: { user: { email: user.email, password: user.password } }
      end

      context 'with valid parameters' do
        let(:valid_params) do
          {
            user: {
              email: 'updated@example.com',
              current_password: 'password123'
            }
          }
        end

        it 'updates the user email' do
          patch user_registration_path, params: valid_params
          user.reload
          expect(user.email).to eq('updated@example.com')
        end

        it 'redirects to root path' do
          patch user_registration_path, params: valid_params
          expect(response).to redirect_to(root_path)
        end
      end

      context 'with invalid current password' do
        let(:invalid_params) do
          {
            user: {
              email: 'updated@example.com',
              current_password: 'wrong_password'
            }
          }
        end

        it 'does not update the user' do
          patch user_registration_path, params: invalid_params
          user.reload
          expect(user.email).to eq('original@example.com')
        end

        it 'displays error message' do
          patch user_registration_path, params: invalid_params
          expect(response.body).to include('Current password is invalid')
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        patch user_registration_path, params: { user: { email: 'new@example.com' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
