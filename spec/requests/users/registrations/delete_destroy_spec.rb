# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Registrations', type: :request do
  describe 'DELETE /users' do
    let(:user) { create(:user) }

    context 'when user is signed in' do
      before do
        post user_session_path, params: {
          user: { email: user.email, password: 'password123' }
        }
      end

      it 'deletes the user account' do
        expect {
          delete user_registration_path
        }.to change(User, :count).by(-1)
      end

      it 'signs out the user' do
        delete user_registration_path
        expect(controller.current_user).to be_nil
      end

      it 'redirects to root path' do
        delete user_registration_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not signed in' do
      it 'does not delete any user' do
        expect {
          delete user_registration_path
        }.not_to change(User, :count)
      end

      it 'redirects to sign in page' do
        delete user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
