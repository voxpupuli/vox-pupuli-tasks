class AddUniqIndexToRepository2 < ActiveRecord::Migration[6.0]
  def change
    add_index :repositories, :github_id, unique: true
  end
end
