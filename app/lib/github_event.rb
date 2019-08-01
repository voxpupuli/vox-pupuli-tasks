class GithubEvent
  attr_reader :processor
  delegate :process, to: :processor

  ##
  # The GithubEvent handler checks which type of event we are dealing with.
  #
  # If it is a known event, create a specific handler and let it take care of
  # the next steps. If not kick off a Sentry error.

  def initialize(payload, type)
    case type
    when 'pull_request'
      @processor = GithubEvent::PullRequest.new(payload) if Repository.notably? payload['repository']['name']
    else
      Raven.capture_message("Unknown Hook Received: #{type}", extra: payload)
    end
  end
end
