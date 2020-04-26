class AddDescriptionToLabels < ActiveRecord::Migration[6.0]
  def change
    add_column :labels, :description, :string
  end
end
