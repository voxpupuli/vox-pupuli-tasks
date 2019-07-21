class Github
  def self.client
    @client ||= Octokit::Client.new(
      auto_paginate: true,
      access_token: Rails.application.credentials.github[Rails.env.to_sym][:bot_token]
    )
  end

  # some convenience methods
  # todo: store labels as json/yaml. We already have someting similar in the plumbing repo

  def remove_label_on_pr(label, repository)
    client.remove_label(repository, pr, label)
  end

  def add_label_on_pr(label, repository, pr_id)
    # We assume that the label exists on the repository
    client.add_labels_to_an_issue(repository, pr_id, [label])
  end

  def add_labels_on_pr(labels, repository, pr_id)
    # We assume that the labels exists on the repository
    client.add_labels_to_an_issue(repository, pr_id, labels)
  end

  def remove_label_on_repo(label, repository)
    # this method should only get the label name and do a lookup of the rest (see line 10)
    # https://octokit.github.io/octokit.rb/Octokit/Client/Labels.html#add_label-instance_method
    # todo: how to add a description
    cient.add_label(repository, label, 'cccccc')
  end

  def add_label_on_repo(label, repository)
    cient.delete_label!(repository, label)
  end

  def repo_label?(label, repository)
    # check if a repository already has a specific label
    # we could also catch Octokit::NotFound:
    client.label(repository, label) ? true : false
  end
end
