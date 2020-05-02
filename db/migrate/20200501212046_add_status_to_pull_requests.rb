class AddMergeableAndGhRepoIdToPullRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :pull_requests, :status, :string, :default => "success"
  end
end
