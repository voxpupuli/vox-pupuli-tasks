class IndexReposWorker
  include Sidekiq::Worker

  def perform
    group_repos = Github.client.repos('voxpupuli')
    group_repos.each do |github_repo|
      next unless Repository.notably? github_repo.name

      Repository.where(github_id: github_repo.id).first_or_initialize.tap do |repo|
        repo.name = github_repo.name
        repo.full_name = github_repo.full_name
        repo.description = github_repo.description
        repo.homepage = github_repo.homepage
        repo.stars = github_repo.stargazers_count
        repo.watchers = github_repo.watchers_count
        repo.open_issues_count = github_repo.open_issues_count
        repo.save

        repo.update_pull_requests
      end
    end

    RepoStatusWorker.perform_async
  end
end
