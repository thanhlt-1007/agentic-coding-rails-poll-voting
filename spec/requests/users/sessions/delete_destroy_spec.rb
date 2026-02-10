# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Sessions', type: :request do
  let(:user) { create(:user, email: 'user@example.com', password: 'password123') }

  describe 'DELETE /users/sign_out' do
    context 'when user is signed in' do
      before do
        post user_session_path, params: {
          user: { email: user.email, password: 'password123' }
        }
      end

      it 'signs out the user' do
        delete destroy_user_session_path
        expect(controller.current_user).to be_nil
      end

      it 'redirects to root path' do
        delete destroy_user_session_path
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success flash message' do
        delete destroy_user_session_path
        expect(flash[:notice]).to eq('Signed out successfully.')
      end

      it 'clears the session' do
        delete destroy_user_session_path
        expect(session[:user_id]).to be_nil
      end
    end

    context 'when user is not signed in' do
      it 'redirects to root path' do
        delete destroy_user_session_path
        expect(response).to redirect_to(root_path)
      end

      it 'does not raise an error' do
        expect {
          delete destroy_user_session_path
        }.not_to raise_error
      end
    end
  end
end
