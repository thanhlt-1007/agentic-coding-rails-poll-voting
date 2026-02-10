module PollsHelper
  def shareable_poll_url(poll)
    poll_url(poll.access_code)
  end
end
