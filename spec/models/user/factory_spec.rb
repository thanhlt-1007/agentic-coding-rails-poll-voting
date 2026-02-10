# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'saves a user to the database' do
      expect { create(:user) }.to change(User, :count).by(1)
    end
  end
end
