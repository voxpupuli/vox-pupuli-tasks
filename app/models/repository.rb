class Repository < ApplicationRecord
  has_many :pull_requests
  has_many :open_pull_requests, -> { where(state: 'open') }, class_name: 'PullRequest'

  def update_pull_requests
    open_pull_requests = Github.client.pull_requests("voxpupuli/#{name}")
    closed_pull_requests = Github.client.pull_requests("voxpupuli/#{name}", state: :closed)
    (open_pull_requests + closed_pull_requests).each do |gh_pull_request|
      PullRequest.where(repository_id: id, number: gh_pull_request.number).first_or_initialize.tap do |pull_request|
        pull_request.number = gh_pull_request.number
        pull_request.state = gh_pull_request.state
        pull_request.title = gh_pull_request.title
        pull_request.body = gh_pull_request.body
        pull_request.gh_created_at = gh_pull_request.created_at
        pull_request.gh_updated_at = gh_pull_request.updated_at
        pull_request.closed_at = gh_pull_request.closed_at
        pull_request.merged_at = gh_pull_request.merged_at
        pull_request.save

        gh_pull_request.labels.each do |label|
          pull_request.labels << Label.find_or_create_by(name: label.name, color: label.color)
        end
      end
    end

    pull_requests.count
  end
end
