class AddDefaultToEligibleForCommentInPullRequestsModell < ActiveRecord::Migration[6.0]
  def change
    change_column :pull_requests, :eligible_for_comment, :boolean, :default => true
  end
end
