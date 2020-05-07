class ChangePullRequestStatus < ActiveRecord::Migration[6.0]
  def change
    change_column_default :pull_requests, :status, from: "success", to: nil
  end
end
