# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'devise modules' do
    it 'includes database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes validatable module' do
      expect(User.devise_modules).to include(:validatable)
    end
  end
end
