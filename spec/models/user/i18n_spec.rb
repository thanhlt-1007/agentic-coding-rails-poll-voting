# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'i18n translations' do
    describe 'model name' do
      it 'returns translated singular model name' do
        expect(User.model_name.human).to eq('User')
      end

      it 'returns translated plural model name' do
        expect(User.model_name.human.pluralize).to eq('Users')
      end
    end

    describe 'attribute names' do
      it 'returns translated email attribute' do
        expect(User.human_attribute_name(:email)).to eq('Email')
      end

      it 'returns translated password attribute' do
        expect(User.human_attribute_name(:password)).to eq('Password')
      end

      it 'returns translated password_confirmation attribute' do
        expect(User.human_attribute_name(:password_confirmation)).to eq('Password confirmation')
      end

      it 'returns translated current_password attribute' do
        expect(User.human_attribute_name(:current_password)).to eq('Current password')
      end

      it 'returns translated remember_me attribute' do
        expect(User.human_attribute_name(:remember_me)).to eq('Remember me')
      end

      it 'returns translated created_at attribute' do
        expect(User.human_attribute_name(:created_at)).to eq('Created at')
      end

      it 'returns translated updated_at attribute' do
        expect(User.human_attribute_name(:updated_at)).to eq('Updated at')
      end
    end
  end
end
