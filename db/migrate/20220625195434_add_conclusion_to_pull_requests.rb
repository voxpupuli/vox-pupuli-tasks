class AddConclusionToPullRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :pull_requests, :conclusion, :string
  end
end
