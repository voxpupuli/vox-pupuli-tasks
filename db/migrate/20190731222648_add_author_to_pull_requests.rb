class AddEligibleForCommentToPullRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :pull_requests, :eligible_for_comment, :boolean
  end
end
