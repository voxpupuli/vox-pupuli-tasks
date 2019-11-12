# frozen_string_literal: true

class GithubEvent
  class PullRequest < GithubEvent::Base
    attr_reader :gh_pull_request

    ##
    # Currently we only care about syncing our database with GitHub as our validation
    # will take action if necessary.

    def process
      ::PullRequest.update_with_github(payload['pull_request'])

      ##
      # if a PullRequest action is closed and the PullRequest merged we want to recheck all
      # other PulRequests in that repo to make sure we catch all new merge conflicts.
      return unless payload['action'] == 'closed' && payload.dig('pull_request', 'merged')

      Repository.find_by(github_id: payload.dig('repository', 'id'))
                .update_pull_requests(only_open: true)
    end
  end
end
