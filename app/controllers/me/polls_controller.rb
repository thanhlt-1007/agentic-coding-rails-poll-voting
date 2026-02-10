# frozen_string_literal: true

module Me
  class PollsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_poll!, only: :show

    def new
      @poll = Poll.new
      4.times { @poll.answers.build }
    end

    def create
      @poll = current_user.polls.build(poll_params)

      if @poll.save
        redirect_to me_poll_path(@poll), notice: t(".success")
      else
        flash.now[:alert] = t(".error")
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    private

    def authenticate_poll!
      @poll = current_user.polls.find_by(id: params[:id])
      return if @poll

      redirect_to root_path, alert: t(".errors.poll_not_found")
    end

    def poll_params
      params.require(:poll).permit(:question, :deadline, answers_attributes: [ :text, :position ])
    end
  end
end
