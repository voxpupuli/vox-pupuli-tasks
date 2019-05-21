class CreateRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :full_name
      t.string :description
      t.string :homepage
      t.integer :stars
      t.integer :watchers
      t.integer :open_issues_count
      t.integer :github_id

      t.timestamps
    end
  end
end
