# frozen_string_literal: true

class Travis < ApplicationRecord
  belongs_to(:pull_requests)

  def self.update_with_travis_payload(payload)
    Travis.where(travis_id: payload['id']).first_or_initialize.tap do |travis|
      travis.type                = payload['type']
      travis.state               = payload['state']
      travis.status              = payload['status']
      travis.result              = payload['result']
      travis.status_message      = payload['status_message']
      travis.result_message      = payload['result_message']
      travis.started_at          = payload['started_at']
      travis.finished_at         = payload['finished_at']
      travis.duration            = payload['duration']
      travis.build_url           = payload['build_url']
      travis.commit_id           = payload['commit_id']
      travis.commit              = payload['commit']
      travis.base_commit         = payload['base_commit']
      travis.head_commit         = payload['head_commit']
      travis.branch              = payload['branch']
      travis.message             = payload['message']
      travis.compare_url         = payload['compare_url']
      travis.committed_at        = payload['committed_at']
      travis.author_name         = payload['author_name']
      travis.author_email        = payload['author_email']
      travis.committer_name      = payload['committer_name']
      travis._committer_email    = payload['committer_email']
      travis.pull_request        = payload['pull_request']
      travis.pull_request_number = payload['payload_request_number']
      travis.request_title       = payload['request_title']
      travis.tag                 = payload['tag']
    end
  end
end
