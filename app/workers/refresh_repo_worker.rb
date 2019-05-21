class RefreshRepoWorker
  include Sidekiq::Worker

  def perform(repo_name)
    github_repo = Github.client.repo("voxpupuli/#{repo_name}")

    Repository.where(github_id: github_repo.id).first_or_initialize.tap do |repo|
      repo.name = github_repo.name
      repo.full_name = github_repo.full_name
      repo.description = github_repo.description
      repo.homepage = github_repo.homepage
      repo.stars = github_repo.stargazers_count
      repo.watchers = github_repo.watchers_count
      repo.open_issues_count = github_repo.open_issues_count
      repo.save
    end
  end
end
