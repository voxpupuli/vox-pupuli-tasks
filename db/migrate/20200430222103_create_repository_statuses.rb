class CreateRepositoryStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :repository_statuses do |t|
      t.json :checks, default: {}

      t.integer :repository_id

      t.timestamps
    end
  end
end
