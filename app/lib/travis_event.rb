# frozen_string_literal: true

class TravisEvent
  attr_reader :processor

  delegate :process, to: :processor

  ##
  # The TravisEvent handler checks which type of event we are dealing with.
  #
  # If it is a known event, create a specific handler and let it take care of
  # the next steps. If not kick off a Sentry error.

  def initialize(payload)
    Sentry.capture_message('Unknown Travis Event Received', extra: payload)
    # case payload['type']
    # when 'push'
    #  TravisEvent::Push.new(payload)
    # when 'pull_request'
    #  TravisEvent::Push.new(payload)
    # when 'cron'
    #  TravisEvent::Push.new(payload)
    # when 'api'
    #  TravisEvent::Push.new(payload)
    # else
    #  Sentry.capture_message("Unknown Hook Received: #{payload['type']}", extra: payload)
    # end
  end
end
