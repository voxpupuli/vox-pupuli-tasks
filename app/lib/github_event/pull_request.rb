class GithubEvent
  class PullRequest < GithubEvent::Base
    attr_reader :gh_pull_request

    ##
    # Currently we only care about syncing our database with GitHub as our validation
    # will take action if necessary.

    def process
      ::PullRequest.update_with_github(payload['pull_request'])
    end
  end
end
