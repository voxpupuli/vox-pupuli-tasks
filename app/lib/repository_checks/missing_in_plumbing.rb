# frozen_string_literal: true

class MissingInPlumbing < RepositoryCheckBase
  def perform
    submit_result :in_plumbing, RepoStatusData.plumbing_modules.include?(repo.name)
  end
end
