class AddTodosToRepository < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :todos, :json, default: {}
  end
end
