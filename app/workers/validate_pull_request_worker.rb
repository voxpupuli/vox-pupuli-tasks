# frozen_string_literal: true

class ValidatePullRequestWorker
  include Sidekiq::Worker

  ##
  # As validation may take a bit more time we do it async.
  # This worker is not meant to hold any logic but only trigger the
  # validation in its asyncronous context.

  def perform(id)
    PullRequest.find(id).validate
  end
end
