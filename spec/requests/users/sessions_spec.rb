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
      before { sign_in user }

      it 'redirects to root path' do
        get new_user_session_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

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
        follow_redirect!
        expect(response.body).to include('Signed out successfully.')
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

  describe 'Session persistence' do
    let(:valid_params) do
      {
        user: {
          email: user.email,
          password: 'password123'
        }
      }
    end

    it 'maintains session across requests' do
      post user_session_path, params: valid_params
      expect(controller.current_user).to eq(user)

      get root_path
      expect(controller.current_user).to eq(user)
    end

    it 'clears session after sign out' do
      post user_session_path, params: valid_params
      expect(controller.current_user).to eq(user)

      delete destroy_user_session_path
      expect(controller.current_user).to be_nil

      get root_path
      expect(controller.current_user).to be_nil
    end
  end

  describe 'Authentication flow' do
    it 'completes full authentication cycle' do
      # Start as guest
      get root_path
      expect(controller.current_user).to be_nil

      # Sign in
      post user_session_path, params: {
        user: { email: user.email, password: 'password123' }
      }
      expect(controller.current_user).to eq(user)

      # Access protected resource
      get edit_user_registration_path
      expect(response).to have_http_status(:success)

      # Sign out
      delete destroy_user_session_path
      expect(controller.current_user).to be_nil

      # Try to access protected resource
      get edit_user_registration_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
