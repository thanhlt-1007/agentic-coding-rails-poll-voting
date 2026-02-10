# frozen_string_literal: true

class PollsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_poll!, only: :show

  def index
    @filter = params[:filter] || 'all'
    polls = Poll.where.not(user_id: current_user.id)
    
    case @filter
    when 'active'
      polls = polls.active
    when 'expired'
      polls = polls.expired
    end
    
    @pagy, @polls = pagy(polls.recent, limit: 12)
  end

  def show
  end

  private

  def authenticate_poll!
    @poll = Poll.where.not(user_id: current_user.id).find_by(id: params[:id])
    return if @poll

    redirect_to polls_path, alert: t("polls_controller.show.errors.poll_not_found")
  end
end
