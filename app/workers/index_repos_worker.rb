class IndexReposWorker
  include Sidekiq::Worker

  def perform
    group_repos = Github.client.repos('voxpupuli')
    repos = []
    group_repos.each do |repo|
      repos << repo[:name] if repo[:name] =~ /^puppet-(?!lint)/
    end

    repos -= LEGACY_OR_BROKEN_NOBODY_KNOWS

    repos.each do |repo|
      RefreshRepoWorker.perform_async(repo)
    end
  end
end
