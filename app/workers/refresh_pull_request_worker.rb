# frozen_string_literal: true

class RefreshPullRequestWorker
  include Sidekiq::Worker

  def perform(repo, number)
    pull_request = Github.client.pull_request("voxpupuli/#{repo}", number)
    PullRequest.update_with_github(pull_request)
  end
end
