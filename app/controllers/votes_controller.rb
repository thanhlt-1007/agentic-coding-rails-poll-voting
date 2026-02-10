class VotesController < ApplicationController
  before_action :set_poll
  before_action :check_duplicate_vote

  def create
    choice = Choice.find(vote_params[:choice_id])
    @vote = Vote.new(
      poll: @poll,
      choice: choice,
      participant_fingerprint: current_participant_fingerprint,
      ip_hash: Digest::SHA256.hexdigest(request.remote_ip),
      session_token: Digest::SHA256.hexdigest(session.id.to_s)
    )

    if @vote.save
      redirect_to poll_url(@poll.access_code), notice: "Thank you for voting!"
    else
      redirect_to poll_url(@poll.access_code), alert: @vote.errors.full_messages.first
    end
  end

  private

  def set_poll
    @poll = Poll.find_by!(access_code: params[:poll_access_code])
  end

  def check_duplicate_vote
    if @poll.votes.exists?(participant_fingerprint: current_participant_fingerprint)
      redirect_to poll_url(@poll.access_code), alert: "You have already voted on this poll" and return
    end
  end

  def current_participant_fingerprint
    # Use cookies for stable session tracking across requests
    cookies.signed[:participant_id] ||= SecureRandom.hex(32)
    Digest::SHA256.hexdigest("#{request.remote_ip || '127.0.0.1'}-#{request.user_agent || 'test'}-#{cookies.signed[:participant_id]}")
  end

  def vote_params
    params.require(:vote).permit(:choice_id)
  end
end