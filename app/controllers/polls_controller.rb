class PollsController < ApplicationController
  def new
    @poll = Poll.new
    3.times { @poll.choices.build }
  end

  def create
    @poll = Poll.new(poll_params)
    
    if @poll.save
      redirect_to poll_url(@poll.access_code), notice: "Poll was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @poll = Poll.find_by!(access_code: params[:access_code])
    @participant_voted = @poll.votes.exists?(participant_fingerprint: current_participant_fingerprint)
    @vote = Vote.new(poll: @poll) unless @participant_voted
  end

  private

  def current_participant_fingerprint
    # Use cookies for stable session tracking across requests
    cookies.signed[:participant_id] ||= SecureRandom.hex(32)
    Digest::SHA256.hexdigest("#{request.remote_ip || '127.0.0.1'}-#{request.user_agent || 'test'}-#{cookies.signed[:participant_id]}")
  end

  def poll_params
    params.require(:poll).permit(
      :question, 
      :deadline, 
      :show_results_while_voting,
      choices_attributes: [:id, :text, :position, :_destroy]
    )
  end
end
