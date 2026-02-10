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
  end

  private

  def poll_params
    params.require(:poll).permit(
      :question, 
      :deadline, 
      :show_results_while_voting,
      choices_attributes: [:id, :text, :position, :_destroy]
    )
  end
end
