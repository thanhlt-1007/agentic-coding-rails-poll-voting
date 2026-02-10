# frozen_string_literal: true

class UserAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_poll!

  def create
    @user_answer = current_user.user_answers.build(user_answer_params)
    @user_answer.poll = @poll

    if @user_answer.save
      redirect_to poll_path(@poll), notice: t(".success")
    else
      redirect_to poll_path(@poll), alert: t(".error", errors: @user_answer.errors.full_messages.to_sentence)
    end
  rescue ActionController::ParameterMissing
    redirect_to poll_path(@poll), alert: t(".errors.no_answer_selected")
  end

  private

  def authenticate_poll!
    # Find poll that belongs to other users only
    @poll = Poll.where.not(user_id: current_user.id).find_by(id: params[:poll_id])
    
    unless @poll
      redirect_to polls_path, alert: t("user_answers.create.errors.poll_not_found")
      return
    end
    
    if @poll.deadline <= Time.current
      redirect_to polls_path, alert: t("user_answers.create.errors.poll_expired")
      return
    end
    
    if current_user.user_answers.exists?(poll_id: @poll.id)
      redirect_to poll_path(@poll), alert: t("user_answers.create.errors.poll_answered")
      return
    end
  end

  def user_answer_params
    params.require(:user_answer).permit(:answer_id)
  end
end
