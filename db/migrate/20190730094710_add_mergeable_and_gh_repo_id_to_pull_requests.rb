class AddMergeableAndGhRepoIdToPullRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :pull_requests, :mergeable, :boolean
    add_column :pull_requests, :gh_repository_id, :integer
    add_column :pull_requests, :github_id, :integer
  end
end
