# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorHelper, type: :helper do
  describe '#field_error_message' do
    let(:user) { User.new }

    context 'when field has errors' do
      before do
        user.errors.add(:email, "can't be blank")
      end

      it 'returns error message paragraph' do
        result = helper.field_error_message(user, :email)
        expect(result).to include('blank')
        expect(result).to include('text-red-700')
        expect(result).to include('<p')
      end

      it 'shows only the first error when multiple errors exist' do
        user.errors.add(:email, 'is invalid')
        result = helper.field_error_message(user, :email)
        expect(result).to include('blank')
        expect(result).not_to include('is invalid')
      end
    end

    context 'when field has no errors' do
      it 'returns nil' do
        result = helper.field_error_message(user, :email)
        expect(result).to be_nil
      end
    end

    context 'with different field names' do
      it 'works with password field' do
        user.errors.add(:password, 'is too short')
        result = helper.field_error_message(user, :password)
        expect(result).to include('is too short')
      end

      it 'works with password_confirmation field' do
        user.errors.add(:password_confirmation, "doesn't match Password")
        result = helper.field_error_message(user, :password_confirmation)
        expect(result).to include('match Password')
      end
    end
  end

  describe '#field_icon_color' do
    let(:user) { User.new }

    context 'when field has errors' do
      before do
        user.errors.add(:email, "can't be blank")
      end

      it 'returns red color class' do
        result = helper.field_icon_color(user, :email)
        expect(result).to eq('text-red-400')
      end
    end

    context 'when field has no errors' do
      it 'returns gray color class' do
        result = helper.field_icon_color(user, :email)
        expect(result).to eq('text-gray-400')
      end
    end

    context 'with different field names' do
      it 'works with password field' do
        user.errors.add(:password, 'is too short')
        result = helper.field_icon_color(user, :password)
        expect(result).to eq('text-red-400')
      end

      it 'works with password_confirmation field' do
        result = helper.field_icon_color(user, :password_confirmation)
        expect(result).to eq('text-gray-400')
      end
    end
  end
end
