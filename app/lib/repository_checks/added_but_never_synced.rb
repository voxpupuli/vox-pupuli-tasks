# frozen_string_literal: true

class AddedButNeverSynced < RepositoryCheckBase
  def perform
    submit_result :added_and_synced, Github.check_file(repo.full_name, '.msync.yml')
  end
end
