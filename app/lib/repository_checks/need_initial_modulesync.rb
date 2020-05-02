# frozen_string_literal: true

class NeedInitialModulesync < RepositoryCheckBase
  def perform
    submit_result :has_modulesync, (RepoStatusData.modulesync_repos.include?(repo.name) ||
                                    LEGACY_OR_BROKEN_NOBODY_KNOWS.include?(repo.name))
  end
end
