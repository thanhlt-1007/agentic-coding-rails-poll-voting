# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserAnswer, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:poll) }
    it { should belong_to(:answer) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:poll) { create(:poll, :with_answers) }
    let(:answer) { poll.answers.first }

    it 'is valid with valid attributes' do
      user_answer = UserAnswer.new(user: user, poll: poll, answer: answer)
      expect(user_answer).to be_valid
    end

    it 'prevents user from answering the same poll twice' do
      UserAnswer.create!(user: user, poll: poll, answer: answer)
      duplicate = UserAnswer.new(user: user, poll: poll, answer: poll.answers.second)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already answered this poll")
    end

    it 'allows different users to answer the same poll' do
      user2 = create(:user)
      UserAnswer.create!(user: user, poll: poll, answer: answer)
      user_answer2 = UserAnswer.new(user: user2, poll: poll, answer: answer)
      
      expect(user_answer2).to be_valid
    end

    it 'allows the same user to answer different polls' do
      poll2 = create(:poll, :with_answers)
      UserAnswer.create!(user: user, poll: poll, answer: answer)
      user_answer2 = UserAnswer.new(user: user, poll: poll2, answer: poll2.answers.first)
      
      expect(user_answer2).to be_valid
    end

    it 'validates that answer belongs to the poll' do
      other_poll = create(:poll, :with_answers)
      other_answer = other_poll.answers.first
      user_answer = UserAnswer.new(user: user, poll: poll, answer: other_answer)
      
      expect(user_answer).not_to be_valid
      expect(user_answer.errors[:answer]).to include("must belong to the specified poll")
    end
  end

  describe 'database constraints' do
    let(:user) { create(:user) }
    let(:poll) { create(:poll, :with_answers) }
    let(:answer) { poll.answers.first }

    it 'enforces unique index on user_id and poll_id' do
      UserAnswer.create!(user: user, poll: poll, answer: answer)
      
      duplicate = UserAnswer.new(user: user, poll: poll, answer: poll.answers.second)
      expect {
        duplicate.save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
