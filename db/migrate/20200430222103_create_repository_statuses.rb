class CreateRepositoryStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :repository_statuses do |t|
      t.boolean :missing_in_plumbing
      t.boolean :need_initial_modulesync
      t.boolean :need_initial_release
      t.boolean :without_reference_dot_md
      t.boolean :added_but_never_synced
      t.boolean :missing_in_modulesync_repo
      t.boolean :needs_another_sync
      t.boolean :never_synced
      t.boolean :missing_secrets
      t.boolean :broken_metadata
      t.boolean :incorrect_puppet_version_range
      t.boolean :without_puppet_version_range
      t.boolean :supports_eol_ubuntu
      t.boolean :doesnt_support_latest_ubuntu
      t.boolean :supports_eol_debian
      t.boolean :supports_eol_centos
      t.boolean :doesnt_support_latest_centos
      t.boolean :supports_eol_freebsd
      t.boolean :doesnt_support_latest_freebsd
      t.boolean :supports_eol_fedora
      t.boolean :doesnt_support_latest_fedora
      t.boolean :without_operatingsystems_support

      t.integer :repository_id

      t.timestamps
    end
  end
end
