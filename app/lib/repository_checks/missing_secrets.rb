# frozen_string_literal: true

class MissingSecrets < RepositoryCheckBase
  def perform
    submit_result :has_secrets = Github.get_file(repo.full_name, '.sync.yml')
  end
end
