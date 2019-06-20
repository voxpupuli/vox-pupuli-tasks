class CreateLabelsPullRequests < ActiveRecord::Migration[5.2]
  def change
    create_table "labels_pull_requests", id: false, force: :cascade do |t|
      t.integer "label_id", null: false
      t.integer "pull_request_id", null: false
    end
  end
end
