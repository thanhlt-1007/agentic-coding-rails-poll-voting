# frozen_string_literal: true

class UserAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_poll

  def create
    @user_answer = current_user.user_answers.build(user_answer_params)
    @user_answer.poll = @poll

    if @user_answer.save
      redirect_to poll_path(@poll), notice: t(".success")
    else
      redirect_to poll_path(@poll), alert: t(".error", errors: @user_answer.errors.full_messages.to_sentence)
    end
  end

  private

  def set_poll
    @poll = Poll.find(params[:poll_id])
  end

  def user_answer_params
    params.require(:user_answer).permit(:answer_id)
  end
end
