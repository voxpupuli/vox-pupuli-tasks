class AddEligibleForCiComment < ActiveRecord::Migration[6.0]
  def change
    add_column :pull_requests, :eligible_for_ci_comment, :boolean, :default => true
  end
end
