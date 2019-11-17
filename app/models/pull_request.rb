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
      pull_request.number           = gh_pull_request['number']
      pull_request.state            = gh_pull_request['state']
      pull_request.title            = gh_pull_request['title']
      pull_request.body             = gh_pull_request['body']
      pull_request.gh_created_at    = gh_pull_request['created_at']
      pull_request.gh_updated_at    = gh_pull_request['updated_at']
      pull_request.gh_repository_id = gh_pull_request['base']['repo']['id']
      pull_request.closed_at        = gh_pull_request['closed_at']
      pull_request.merged_at        = gh_pull_request['merged_at']
      pull_request.mergeable        = gh_pull_request['mergeable']
      pull_request.author           = gh_pull_request['user']['login']
      pull_request.save

      gh_pull_request['labels'].each do |label|
        db_label = Label.find_or_create_by(name: label['name'], color: label['color'])

        next if pull_request.labels.include? db_label

        pull_request.labels << db_label
      end
    end
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
    Raven.capture_message('Going to attach a label',
                          extra: { label: label,
                                   repo: repository.github_url,
                                   title: title })

    repository.ensure_label_exists(label)
    attached_labels = Github.client.labels_for_issue(gh_repository_id, number)
    return if attached_labels.any? { |attached_label| attached_label['name'] == label.name }

    Github.client.add_labels_to_an_issue(gh_repository_id, number, [label.name])
  end

  ##
  #  We simply remove the given Label if it exists

  def ensure_label_is_detached(label)
    Raven.capture_message('Going to detach a label',
                          extra: { label: label,
                                   repo: repository.github_url,
                                   title: title })

    Github.client.remove_label(gh_repository_id, number, label.name)
  rescue Octokit::NotFound
    true
  end

  ##
  #  Add a comment with the given text
  def add_comment(text)
    Raven.capture_message('Going to add a comment',
                          extra: { text: text,
                                   repo: repository.github_url,
                                   title: title,
                                   request: request || nil })

    ##
    # disabled for debug
    #Github.client.add_comment(gh_repository_id, number, text)
    #update(eligible_for_comment: false)
  end

  def eligible_for_comment
    return true if super.nil?

    super
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

  def validate(saved_changes)
    # Don't run through the validaten, if only the eligable_for_comment attribute got updated
    return if saved_changes.keys.sort == %w[updated_at eligable_for_comment].sort && !mergeable.nil?

    # if the pull request is now closed, dont attach/remove labels/comments
    return if closed?

    label = Label.needs_rebase
    if mergeable == true
      ensure_label_is_detached(label)
      update(eligible_for_comment: true)
    elsif mergeable == false
      repository.ensure_label_exists(label)
      ensure_label_is_attached(label)
      add_comment(I18n.t('comment.needs_rebase', author: author)) if eligible_for_comment
    elsif mergeable.nil?
      UpdateMergeableWorker.perform_in(1.minute.from_now,
                                       repository.name,
                                       number,
                                       id,
                                       saved_changes)
    end
  end

  private

  ##
  #  Since we want to be a fancy responsive application we to all the validation
  #  stuff which might result in some new querys and api requests asyncronously.

  def queue_validation
    ValidatePullRequestWorker.perform_async(id, saved_changes) if saved_changes? || mergeable.nil?
  end
end
