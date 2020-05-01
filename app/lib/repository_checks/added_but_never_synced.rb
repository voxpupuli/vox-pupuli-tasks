# frozen_string_literal: true

class AddedButNeverSynced < RepositoryCheckBase
  def perform(repo)
    repo.added_but_never_synced = !Github.get_file(repo.full_name, '.msync.yml')
  end
end
