class AddUniqIndexToRepository < ActiveRecord::Migration[6.0]
  def change
    add_index :repositories, :name, unique: true
  end
end
