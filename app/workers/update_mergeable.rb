# frozen_string_literal: true

class UpdateMergeableWorker
  include Sidekiq::Worker

  def perform(repo, number, id, saved_changes)
    pull_request = Github.client.pull_request("voxpupuli/#{repo}", number)
    PullRequest.update_with_github(pull_request)
    ValidatePullRequestWorker.perform_async(id, saved_changes)
  end
end
