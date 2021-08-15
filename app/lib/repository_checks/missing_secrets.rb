# frozen_string_literal: true

class MissingSecrets < RepositoryCheckBase
  def perform
    secrets_file = Github.get_file(repo.full_name, '.sync.yml')

    if secrets_file
      content = YAML.safe_load(secrets_file)
      submit_result :has_secrets, !content.dig('.travis.yml', 'secure').nil?
    else
      submit_result :has_secrets, false
    end
  rescue StandardError => e
    submit_result :has_secrets, false

    ##
    # We reraise the error to get handled by Sentry but rescue it
    # first to make sure the check has a valid (false) state
    raise
  end
end
