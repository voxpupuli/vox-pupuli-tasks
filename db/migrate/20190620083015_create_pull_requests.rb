class CreatePullRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :pull_requests do |t|
      t.integer :number
      t.string :state
      t.string :title
      t.string :body
      t.timestamp :gh_created_at
      t.timestamp :gh_updated_at
      t.timestamp :closed_at
      t.timestamp :merged_at
      t.references :repository, foreign_key: true

      t.timestamps
    end
  end
end
