class RefreshRepoWorker
  include Sidekiq::Worker

  # Fetch related information based on the locally cached repository
  def perform(repo_id)
  end
end
