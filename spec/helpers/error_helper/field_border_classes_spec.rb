# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorHelper, type: :helper do
  describe '#field_border_classes' do
    let(:user) { User.new }

    context 'when field has errors' do
      before do
        user.errors.add(:email, "can't be blank")
      end

      it 'returns red border classes' do
        result = helper.field_border_classes(user, :email)
        expect(result).to eq('border-red-500 focus:border-red-500')
      end
    end

    context 'when field has no errors' do
      it 'returns default border and focus ring classes' do
        result = helper.field_border_classes(user, :email)
        expect(result).to eq('border-gray-300 focus:ring-indigo-500 focus:border-transparent focus:ring-2')
      end
    end

    context 'with different field names' do
      it 'works with password field' do
        user.errors.add(:password, 'is too short')
        result = helper.field_border_classes(user, :password)
        expect(result).to eq('border-red-500 focus:border-red-500')
      end

      it 'works with password_confirmation field' do
        user.errors.add(:password_confirmation, "doesn't match Password")
        result = helper.field_border_classes(user, :password_confirmation)
        expect(result).to eq('border-red-500 focus:border-red-500')
      end
    end
  end
end
