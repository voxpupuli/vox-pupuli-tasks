class FixColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :pull_requests, :eligible_for_comment, :eligible_for_merge_comment
  end
end
