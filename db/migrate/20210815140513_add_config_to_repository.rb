class AddConfigToRepository < ActiveRecord::Migration[6.1]
  def change
    add_column :repositories, :vpt_config, :json, default: {}
  end
end
