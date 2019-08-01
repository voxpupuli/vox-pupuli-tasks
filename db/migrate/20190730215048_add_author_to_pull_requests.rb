class AddAuthorToPullRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :pull_requests, :author, :string
  end
end
