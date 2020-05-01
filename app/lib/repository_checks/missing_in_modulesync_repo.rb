# frozen_string_literal: true

class MissingInModulesyncRepo < RepositoryCheckBase
  def perform(repo)
    repo.missing_in_modulesync_repo = !RepoStatusData.modulesync_repos.include?(repo.name)
  end
end
