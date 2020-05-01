# frozen_string_literal: true

class MissingInPlumbing < RepositoryCheckBase
  def perform(repo)
    repo.missing_in_plumbing = !RepoStatusData.plumbing_modules.include?(repo.name)
  end
end
