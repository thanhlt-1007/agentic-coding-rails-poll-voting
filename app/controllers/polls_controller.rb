# frozen_string_literal: true

class PollsController < ApplicationController
  before_action :authenticate_user!

  def new
    @poll = Poll.new
    4.times { @poll.answers.build }
  end

  def create
    @poll = current_user.polls.build(poll_params)

    if @poll.save
      redirect_to poll_path(@poll), notice: t(".success")
    else
      flash.now[:alert] = t(".error")
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @poll = Poll.find(params[:id])
  end

  private

  def poll_params
    params.require(:poll).permit(:question, :deadline, answers_attributes: [ :text, :position ])
  end
end
