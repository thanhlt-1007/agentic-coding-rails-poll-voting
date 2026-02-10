# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Sessions', type: :request do
  let(:user) { create(:user, email: 'user@example.com', password: 'password123') }

  describe 'POST /users/sign_in' do
    context 'with valid credentials' do
      let(:valid_params) do
        {
          user: {
            email: user.email,
            password: 'password123'
          }
        }
      end

      it 'signs in the user' do
        post user_session_path, params: valid_params
        expect(controller.current_user).to eq(user)
      end

      it 'redirects to root path' do
        post user_session_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success flash message' do
        post user_session_path, params: valid_params
        follow_redirect!
        expect(response.body).to include('Signed in successfully.')
      end
    end

    context 'with invalid email' do
      let(:invalid_params) do
        {
          user: {
            email: 'nonexistent@example.com',
            password: 'password123'
          }
        }
      end

      it 'does not sign in the user' do
        post user_session_path, params: invalid_params
        expect(controller.current_user).to be_nil
      end

      it 'returns unprocessable entity status' do
        post user_session_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'displays error message' do
        post user_session_path, params: invalid_params
        expect(response.body).to include('Invalid Email or password')
      end

      it 'does not create a new session' do
        post user_session_path, params: invalid_params
        expect(session[:user_id]).to be_nil
      end
    end

    context 'with invalid password' do
      let(:invalid_params) do
        {
          user: {
            email: user.email,
            password: 'wrong_password'
          }
        }
      end

      it 'does not sign in the user' do
        post user_session_path, params: invalid_params
        expect(controller.current_user).to be_nil
      end

      it 'returns unprocessable entity status' do
        post user_session_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'displays error message' do
        post user_session_path, params: invalid_params
        expect(response.body).to include('Invalid Email or password')
      end
    end

    context 'with blank email' do
      let(:invalid_params) do
        {
          user: {
            email: '',
            password: 'password123'
          }
        }
      end

      it 'does not sign in the user' do
        post user_session_path, params: invalid_params
        expect(controller.current_user).to be_nil
      end

      it 'displays error message' do
        post user_session_path, params: invalid_params
        expect(response.body).to include('Invalid Email or password')
      end
    end

    context 'with blank password' do
      let(:invalid_params) do
        {
          user: {
            email: user.email,
            password: ''
          }
        }
      end

      it 'does not sign in the user' do
        post user_session_path, params: invalid_params
        expect(controller.current_user).to be_nil
      end

      it 'displays error message' do
        post user_session_path, params: invalid_params
        expect(response.body).to include('Invalid Email or password')
      end
    end

    context 'when user is already signed in' do
      before { sign_in user }

      let(:params) do
        {
          user: {
            email: user.email,
            password: 'password123'
          }
        }
      end

      it 'redirects to root path' do
        post user_session_path, params: params
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with case-insensitive email' do
      let(:params_with_uppercase_email) do
        {
          user: {
            email: user.email.upcase,
            password: 'password123'
          }
        }
      end

      it 'signs in the user successfully' do
        post user_session_path, params: params_with_uppercase_email
        expect(controller.current_user).to eq(user)
      end
    end
  end
end
