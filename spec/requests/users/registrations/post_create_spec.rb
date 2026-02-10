# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Registrations', type: :request do
  describe 'POST /sign_up' do
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
          expect(response.body).to include("can&#39;t be blank")
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
          expect(response.body).to include('is invalid')
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
          expect(response.body).to include('has already been taken')
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
          expect(response.body).to include('is too short')
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
          expect(response.body).to include("doesn&#39;t match Password")
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

      before { sign_in user, scope: :user }

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
end
