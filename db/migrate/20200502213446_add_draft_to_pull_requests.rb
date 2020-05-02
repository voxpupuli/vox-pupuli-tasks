class AddDraftToPullRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :pull_requests, :draft, :boolean, :default => false
  end
end
