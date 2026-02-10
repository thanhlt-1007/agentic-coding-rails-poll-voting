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

      before { sign_in user }

      it 'redirects to root path' do
        get new_user_registration_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST /users' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'signs in the user automatically' do
        post user_registration_path, params: valid_params
        expect(controller.current_user).to be_present
        expect(controller.current_user.email).to eq('newuser@example.com')
      end

      it 'redirects to root path' do
        post user_registration_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success flash message' do
        post user_registration_path, params: valid_params
        follow_redirect!
        expect(response.body).to include('Welcome! You have signed up successfully.')
      end
    end

    context 'with invalid parameters' do
      context 'when email is blank' do
        let(:invalid_params) do
          {
            user: {
              email: '',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end

        it 'does not create a new user' do
          expect {
            post user_registration_path, params: invalid_params
          }.not_to change(User, :count)
        end

        it 'returns unprocessable entity status' do
          post user_registration_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'displays error message' do
          post user_registration_path, params: invalid_params
          expect(response.body).to include("Email can&#39;t be blank")
        end
      end

      context 'when email is invalid format' do
        let(:invalid_params) do
          {
            user: {
              email: 'invalid_email',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end

        it 'does not create a new user' do
          expect {
            post user_registration_path, params: invalid_params
          }.not_to change(User, :count)
        end

        it 'displays error message' do
          post user_registration_path, params: invalid_params
          expect(response.body).to include('Email is invalid')
        end
      end

      context 'when email is already taken' do
        let!(:existing_user) { create(:user, email: 'taken@example.com') }
        let(:invalid_params) do
          {
            user: {
              email: existing_user.email,
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end

        it 'does not create a new user' do
          expect {
            post user_registration_path, params: invalid_params
          }.not_to change(User, :count)
        end

        it 'displays error message' do
          post user_registration_path, params: invalid_params
          expect(response.body).to include('Email has already been taken')
        end
      end

      context 'when password is too short' do
        let(:invalid_params) do
          {
            user: {
              email: 'user@example.com',
              password: '12345',
              password_confirmation: '12345'
            }
          }
        end

        it 'does not create a new user' do
          expect {
            post user_registration_path, params: invalid_params
          }.not_to change(User, :count)
        end

        it 'displays error message' do
          post user_registration_path, params: invalid_params
          expect(response.body).to include('Password is too short')
        end
      end

      context 'when password confirmation does not match' do
        let(:invalid_params) do
          {
            user: {
              email: 'user@example.com',
              password: 'password123',
              password_confirmation: 'different_password'
            }
          }
        end

        it 'does not create a new user' do
          expect {
            post user_registration_path, params: invalid_params
          }.not_to change(User, :count)
        end

        it 'displays error message' do
          post user_registration_path, params: invalid_params
          expect(response.body).to include("Password confirmation doesn&#39;t match Password")
        end
      end
    end

    context 'when user is already signed in' do
      let(:user) { create(:user) }
      let(:params) do
        {
          user: {
            email: 'another@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      before { sign_in user }

      it 'does not create a new user' do
        expect {
          post user_registration_path, params: params
        }.not_to change(User, :count)
      end

      it 'redirects to root path' do
        post user_registration_path, params: params
        expect(response).to redirect_to(root_path)
      end
    end
  end

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

  describe 'PATCH /users' do
    let(:user) { create(:user, email: 'original@example.com') }

    context 'when user is signed in' do
      before { sign_in user }

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
