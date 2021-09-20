# frozen_string_literal: true

class Repository < ApplicationRecord
  # It is easier overall to use the GitHub ID for relation management.
  # It allows us to maintain, update or the Repository or PullRequest without
  # the counterpart.
  has_many(:pull_requests,
           primary_key: :github_id,
           foreign_key: :gh_repository_id,
           inverse_of: :repository,
           dependent: :destroy)
  has_many(:open_pull_requests,
           -> { where(state: 'open') },
           class_name: 'PullRequest',
           primary_key: :github_id,
           foreign_key: :gh_repository_id,
           inverse_of: :repository,
           dependent: :destroy)

  has_many :repository_statuses, dependent: :destroy

  ##
  #  Checks if the given Repository name is in our application scope (a module)
  #
  #  The config can be a hash containing a 'enabled' key.
  #  Only if the key explicitly contains false we skip right away, a missing key does default to true.
  def notably?
    return false if vpt_config['enabled'] == false

    Repository.notably?(name)
  end

  def self.notably?(name)
    /^puppet-(?!lint)/.match?(name) && LEGACY_OR_BROKEN_NOBODY_KNOWS.exclude?(name)
  end

  def actions_needed
    @actions_needed ||= begin
      actions = []
      data = JSON.parse(RedisClient.client.get('repo_status_data').to_s)
      data.each do |action, repos|
        actions << action if repos.include? name
      end
      actions
    rescue JSON::ParserError
      nil
    end
  end

  def github_url
    "https://github.com/#{full_name}"
  end

  ##
  #  Check if the Label exists in the Repository
  #  If we get a 404 create the Label.

  def ensure_label_exists(label)
    Github.client.label(github_id, label.name)
  rescue Octokit::NotFound
    if ENV['DRY_RUN']
      DRY_LOGGER.info("Would create #{label.name} in #{full_name}")
      return
    end

    Github.client.add_label(github_id, label.name, label.color)

    Raven.capture_message('Attached a label to an repository',
                          extra: { label_color: label.color,
                                   label_name: label.name,
                                   repo: github_id })
  end

  ##
  #  Delete the given Label from the Repository
  #
  def ensure_label_missing(label)
    if ENV['DRY_RUN']
      DRY_LOGGER.info("Would delete #{label.name} in #{full_name}")
      return
    end
    Github.client.delete_label!(github_id, label.name)

    Raven.capture_message('Detached a label from an repository',
                          extra: { label_color: label.color,
                                   label_name: label.name,
                                   repo: github_id })
  rescue Octokit::NotFound
    true
  end

  ##
  #  Fetch the Labels for this Repository from GitHub
  #  and create it in our database
  #
  def labels
    @labels ||= Github.client.labels("voxpupuli/#{name}").map do |label|
      Label.find_or_create_by!(name: label[:name],
                               color: label[:color],
                               description: label[:description])
    end
  end

  ##
  #  Find all Labels which are in our config but are missing from the
  #  Repository on GitHub
  #
  def missing_labels
    required_label_names = VOXPUPULI_CONFIG['labels'].map do |label|
      label['name']
    end

    label_names = labels.pluck(:name)

    missing_label_names = required_label_names.reject do |name|
      label_names.include?(name)
    end

    missing_label_names.map do |name|
      Label.find_by(name: name)
    end.compact
  end

  ##
  #  Create each missing Label for the repository on GitHub
  #
  def attach_missing_labels
    missing_labels.each do |label|
      if ENV['DRY_RUN']
        DRY_LOGGER.info("Would attach #{label.name} to #{full_name}")
        next
      end
      ensure_label_exists(label)
    end
  end

  ##
  #  Compare the Labels on GitHub with the ones from our config
  #  If we have the Label in our config but the color or
  #  description differs we update the Label on GitHub to match the config.
  #
  def sync_label_colors_and_descriptions
    config_labels = VOXPUPULI_CONFIG['labels'].map do |label|
      Label.new(name: label['name'],
                color: label['color'],
                description: label['description'])
    end

    labels.each do |label|
      config_label = config_labels.select { |c_label| c_label.name == label.name }.first

      next unless config_label
      next if (label.color == config_label.color) && (label.description == config_label.description)

      if ENV['DRY_RUN']
        DRY_LOGGER.info("Would update github label #{config_label.name}")
        next
      end

      Github.client.update_label(github_id,
                                 config_label.name,
                                 {
                                   color: config_label.color,
                                   description: config_label.description
                                 })
    end
  end

  ##
  #  Fetch all open and closed PullRequests and sync our database with them
  #
  def update_pull_requests(only_open: false)
    open_pull_requests = Github.client.pull_requests("voxpupuli/#{name}")
    closed_pull_requests = if only_open
                             []
                           else
                             Github.client.pull_requests("voxpupuli/#{name}", state: :closed)
                           end

    (open_pull_requests + closed_pull_requests).each do |gh_pull_request|
      PullRequest.update_with_github(gh_pull_request)
    end

    pull_requests.count
  end

  ##
  # Within the .sync.yml you can optionally place some vpt config
  # If there is some content, we set this in the repo to avoid multiple github requests
  # If the file is missing completely, we also remove the config locally.
  def update_vpt_config
    sync_file = Github.get_file(full_name, '.sync.yml')

    if sync_file
      content = YAML.safe_load(sync_file)
      update(vpt_config: content['vpt'].to_h)
    elsif vpt_config.any?
      update(vpt_config: {})
    end
  end

  def healty?
    repository_statuses.last.checks.values.all?
  end

  def current_status
    repository_statuses.last
  end

  def passed_check?(check_name)
    current_status.checks[check_name]
  end

  def fetch_status
    RepositoryStatus.create!(repository_id: id)
  end
end
