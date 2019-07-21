class IncomingController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :logged_in

  def github
    # parse the JSON payload, that we get as string, to a hash
    json_body = JSON.parse(request.body.read)

    Raven.capture_message('Received hook', extra: useable_body.to_h)

    # parse the payload and trigger different actions
    # todo: update the github app to provide us a token that we can validate
    event_type = request.headers['X-GitHub-Event']
    case event_type
    when 'pull_request'
      parse_pull_request(json_body)
      # else # in case we handle all events, we should log unhandled payloads
      #  Raven.capture_message('Unhandled payload', extra: useable_body.to_h)
    end
  end

  # this is now a valid route and sucks balls
  # should this be part of the PullRequest model?
  # How do we serialize the payload to a PullRequest model / how do we sync with our redis/database
  def parse_pull_request(payload)
    # TODO: does it make sense to parse payload['action'] here?

    # get all labels on a PR
    labels = payload['pull_request']['labels']
    # github-wide unique ids
    repository_id = payload['repository']['id']
    pr_id = payload = payload['pull_request']['id']
    # check if a PR is mergeable or not. Set/remove the related label
    if payload['pull_request']['mergeable']
      # isn't mergeable, we need to set a label if it isn't already present
      add_label_on_repo('needs-rebase', repository_id) unless github.repo_label?('needs-rebase', repository_id)
      add_label_on_pr('needs-rebase', repository_id, pr_id) unless labels.any? { |label| label[:name] == 'bla' }
    elsif labels.any? { |label| label['name'] == 'needs-rebase' }
      # is mergeable, we need to remove a label if it is present
      remove_label_on_pr('needs-rebase', repository_id, pr_id)
    end
  end
end
