# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /polls/:poll_id/user_answers', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:poll) { create(:poll, :with_answers, user: other_user) }
  let(:answer) { poll.answers.first }

  before { sign_in user, scope: :user }

  describe 'when creating a user answer' do
    it 'successfully saves the answer' do
      expect {
        post poll_user_answers_path(poll), params: { user_answer: { answer_id: answer.id } }
      }.to change(UserAnswer, :count).by(1)
    end

    it 'redirects to the poll page' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: answer.id } }
      expect(response).to redirect_to(poll_path(poll))
    end

    it 'shows success message' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: answer.id } }
      follow_redirect!
      expect(response.body).to include('Your answer has been saved successfully')
    end

    it 'associates the answer with the current user' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: answer.id } }
      user_answer = UserAnswer.last
      expect(user_answer.user).to eq(user)
    end

    it 'associates the answer with the poll' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: answer.id } }
      user_answer = UserAnswer.last
      expect(user_answer.poll).to eq(poll)
    end

    it 'associates the answer with the selected answer' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: answer.id } }
      user_answer = UserAnswer.last
      expect(user_answer.answer).to eq(answer)
    end
  end

  describe 'when answer already exists for user and poll' do
    before do
      UserAnswer.create!(user: user, poll: poll, answer: answer)
    end

    it 'does not create a duplicate answer' do
      expect {
        post poll_user_answers_path(poll), params: { user_answer: { answer_id: poll.answers.second.id } }
      }.not_to change(UserAnswer, :count)
    end

    it 'redirects to the poll page' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: poll.answers.second.id } }
      expect(response).to redirect_to(poll_path(poll))
    end

    it 'shows error message' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: poll.answers.second.id } }
      follow_redirect!
      expect(response.body).to include('Failed to save your answer')
    end
  end

  describe 'when answer belongs to different poll' do
    let(:other_poll) { create(:poll, :with_answers, user: other_user) }
    let(:other_answer) { other_poll.answers.first }

    it 'does not create the answer' do
      expect {
        post poll_user_answers_path(poll), params: { user_answer: { answer_id: other_answer.id } }
      }.not_to change(UserAnswer, :count)
    end

    it 'shows error message' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: other_answer.id } }
      follow_redirect!
      expect(response.body).to include('Failed to save your answer')
      expect(response.body).to include('must belong to the specified poll')
    end
  end

  describe 'when user is not authenticated' do
    before { sign_out user }

    it 'redirects to login page' do
      post poll_user_answers_path(poll), params: { user_answer: { answer_id: answer.id } }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
