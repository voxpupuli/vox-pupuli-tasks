# frozen_string_literal: true

class ValidSyncFile < RepositoryCheckBase
  ##
  # Since travis is no longer in use, the sync file is optional.
  # But if it exists, it must not contain a .travis.yml entry.
  def perform
    sync_file = Github.get_file(repo.full_name, '.sync.yml')

    if sync_file
      content = YAML.safe_load(secrets_file)
      submit_result :valid_sync_file, !content['.travis.yml']
    else
      submit_result :valid_sync_file, true
    end
  rescue StandardError
    submit_result :valid_sync_file, false

    ##
    # We reraise the error to get handled by Sentry but rescue it
    # first to make sure the check has a valid (false) state
    raise
  end
end
