# frozen_string_literal: true

class GithubEvent
  attr_reader :processor
  delegate :process, to: :processor

  ##
  # The GithubEvent handler checks which type of event we are dealing with.
  #
  # If it is a known event, create a specific handler and let it take care of
  # the next steps. If not kick off a Sentry error.

  def initialize(payload, type)
    known_but_ignoreable_events = %w[
      installation
      issues
      pull_request_review
      issue_comment
      label
      pull_request_review_comment
      installation_repositories
      integration_installation_repositories
      repository
      integration_installation
      ping
      pull_request_review
    ]

    case type
    when 'pull_request'
      ##
      # Ignore events which are triggered by the bot
      return if payload.dig('sender', id).to_i == 53_702_691

      if Repository.notably? payload['repository']['name']
        @processor = GithubEvent::PullRequest.new(payload)
      end
    when *known_but_ignoreable_events
      true
    else
      Raven.capture_message("Unknown Hook Received: #{type}", extra: payload)
    end
  end
end
