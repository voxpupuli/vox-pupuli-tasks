# frozen_string_literal: true

class PullRequest < ApplicationRecord
  # It is easier overall to use the GitHub ID for relation management.
  # It allows us to maintain, update or the Repository or PullRequest without
  # the counterpart.
  belongs_to(:repository,
             primary_key: :github_id,
             foreign_key: :gh_repository_id,
             inverse_of: :pull_requests)

  has_and_belongs_to_many :labels
  after_save :queue_validation

  ##
  # This method is used for updating our database with the current state of the PullRequest
  # in GitHub. Therefore it's used with the payload of the webhook content processed by
  # GithubEvent handler and by the content from the api fetched by the periodic check.

  def self.update_with_github(gh_pull_request)
    PullRequest.where(github_id: gh_pull_request['id']).first_or_initialize.tap do |pull_request|
      # get current status. GitHub API does not expose it as an atttribute of a PR
      # However, https://github.com/search does
      repo_id = gh_pull_request['base']['repo']['id']
      status = begin
        statuses = Github.client.combined_status(repo_id, gh_pull_request['head']['sha'])
        statuses['state']
      rescue StandardError => e
        Raven.capture_message('validate status', extra: { trace: e.backtrace, error: e.inspect, github_data: gh_pull_request.to_h })
        nil
      end
      pull_request.number           = gh_pull_request['number']
      pull_request.state            = gh_pull_request['state']
      pull_request.title            = gh_pull_request['title']
      pull_request.body             = gh_pull_request['body']
      pull_request.gh_created_at    = gh_pull_request['created_at']
      pull_request.gh_updated_at    = gh_pull_request['updated_at']
      pull_request.gh_repository_id = repo_id
      pull_request.closed_at        = gh_pull_request['closed_at']
      pull_request.merged_at        = gh_pull_request['merged_at']
      pull_request.mergeable        = gh_pull_request['mergeable']
      pull_request.author           = gh_pull_request['user']['login']
      pull_request.status           = status
      pull_request.draft            = gh_pull_request['draft']
      pull_request.save

      gh_pull_request['labels'].each do |label|
        db_label = Label.find_or_create_by(name: label['name'], color: label['color'])

        next if pull_request.labels.include? db_label

        pull_request.labels << db_label
      end
    end
  end

  ##
  # helper method to create a github object for the pullrequest
  def github
    @github ||= Github.client.pull_request(gh_repository_id, number)
  end

  ##
  # Shortcut to check if the PullRequest is closed

  def closed?
    state == 'closed'
  end

  ##
  # Shortcut to check if the PullRequest is open

  def open?
    !closed?
  end

  ##
  #  Ensure that the Label is attached to the PullRequest
  #
  #  Therefore ensure that the Label exists for the corresponding repository
  #
  #  Then ensure the Label is attached to this PullRequest by checking the list
  #  of attached Labels. Unfortunately this seems to be the only option
  #
  #  If the list does not include the given Label we attach it

  def ensure_label_is_attached(label)
    if ENV['DRY_RUN']
      DRY_LOGGER.info("Would attach label #{label.name} from #{title} in #{repository.full_name}")
      return
    end

    repository.ensure_label_exists(label)
    attached_labels = Github.client.labels_for_issue(gh_repository_id, number)
    return if attached_labels.any? { |attached_label| attached_label['name'] == label.name }

    response = Github.client.add_labels_to_an_issue(gh_repository_id, number, [label.name])

    Raven.capture_message('Attached a label to an issue', extra: { label: label, repo: repository.github_url, title: title })
    response
  end

  ##
  #  We simply remove the given Label if it exists

  def ensure_label_is_detached(label)
    if ENV['DRY_RUN']
      DRY_LOGGER.info("Would detach label #{label.name} from #{title} in #{repository.full_name}")
      return
    end

    response = Github.client.remove_label(gh_repository_id, number, label.name)

    Raven.capture_message('Detached a label from an issue', extra: { label: label, repo: repository.github_url, title: title })
    response
  rescue Octokit::NotFound
    true
  end

  ##
  # Only attach a comment if eligible_for_merge_comment is true (The first iteration
  # after the mergeable state changed to false)
  def add_merge_comment
    return if vpt_config.dig('comment_on', 'needs_rebase') == false
    return unless eligible_for_merge_comment

    add_comment(I18n.t('comment.needs_rebase', author: author))
    update(eligible_for_merge_comment: false)
  end

  ##
  # Only attach a comment if eligible_for_ci_comment is true (if CI was okay and changed to fail)
  # This logic is required to prevent comments for failure -> pending -> failure
  # Also it prevents duplicate comments
  def add_ci_comment
    return if vpt_config.dig('comment_on', 'tests_failed') == false
    return unless eligible_for_ci_comment

    add_comment(I18n.t('comment.tests_fail', author: author))
    update(eligible_for_ci_comment: false)
  end

  ##
  #  Add a comment with the given text
  def add_comment(text)
    if ENV['DRY_RUN']
      DRY_LOGGER.info("Would add comment to #{title} in #{repository.full_name}")
      return
    end

    # TODO: why can request be nil and what is request
    req = begin
      request
    rescue StandardError
      nil
    end

    Raven.capture_message('Added a comment', extra: { text: text, repo: repository.github_url, title: title, request: req })
    Github.client.add_comment(gh_repository_id, number, text)
  end

  ##
  #  if the PullRequest is mergeable we need to check if the 'merge-conflicts' Label
  #  is attached. If so, we need to remove it.
  #
  #  If the PullRequest is not yet mergeable we need to attach the 'merge-conflicts'
  #  Label. Therefore we also need to check if the Label exists on repository level.
  #
  # The saved_changes variable includes all the stuff that has changed.
  # We currently don't care about them

  def validate
    # Don't run through validation if it's a draft
    return if draft

    # if the pull request is now closed, dont attach/remove labels/comments
    return if closed?

    # If we're running in development mode, we try to run read-only and won't modify PRs
    return if Rails.env.development?

    # check merge status and do work if required
    mergeable_result = validate_mergeable

    # check CI status and do work if required
    status_result = validate_status

    # If one of the checks is nil perform a new check in one minute
    return if mergeable_result && (!status_result.nil? || status != 'pending')

    RefreshPullRequestWorker.perform_in(1.minute.from_now, repository.name, number)
  end

  private

  ##
  # Queue a job into sidekiq that runs the validate() method above
  # validate() might use update() to change attributes which would trigger a new job
  # To prevent loops, we filter `saved_changed` of those attributes and won't create new job if those are the only changed attributes
  def queue_validation
    force = mergeable.nil? || status.nil? || status == 'pending'

    case saved_changes.stringify_keys.keys.sort
    when %w[eligible_for_merge_comment eligible_for_ci_comment].sort
      return unless force
    when %w[eligible_for_ci_comment]
      return unless force
    when %w[eligible_for_merge_comment]
      return unless force
    end

    return if saved_changes.empty? && !force

    ValidatePullRequestWorker.perform_async(id)
  end

  def validate_mergeable
    label = Label.needs_rebase
    if mergeable == true
      ensure_label_is_detached(label)
      update(eligible_for_merge_comment: true)
    elsif mergeable == false
      repository.ensure_label_exists(label)

      ##
      # We only add a comment if we added a label. If the label already is present
      # we also already added the comment. So no need for a new one.
      add_merge_comment if ensure_label_is_attached(label)
    elsif mergeable.nil?
      return false
    end

    true
  end

  def validate_status
    label = Label.tests_fail

    case status
    when 'failure'
      # if CI failed, add a label to PR
      add_ci_comment if ensure_label_is_attached(label)
    when 'success'
      ensure_label_is_detached(label)
      update(eligible_for_ci_comment: true)
    when 'pending'
      RefreshPullRequestWorker.perform_in(5.minutes.from_now, repository.name, number)
      Raven.capture_message('pending PR status', extra: { state: state, status: status, repo: repository.github_url, title: title })
      true
    when nil
      # it's not really clear if the status is ever nil. if so, we should log it to decide if we need to act here
      Raven.capture_message('nil PR status', extra: { state: state, status: status, repo: repository.github_url, title: title })
      return false
    else
      Raven.capture_message('Unknown PR state /o\\', extra: { state: state, status: status, repo: repository.github_url, title: title })
    end

    true
  end
end
