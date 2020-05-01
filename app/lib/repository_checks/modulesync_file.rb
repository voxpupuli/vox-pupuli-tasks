# frozen_string_literal: true

class ModulesyncFile < RepositoryCheckBase
  def perform(repo, status)
    msync_file = Github.get_file(repo.full_name, '.msync.yml')

    if msync_file
      status.never_synced = false
      msync_version = YAML.safe_load(msync_file)['modulesync_config_version']

      status.needs_another_sync = (
        Gem::Version.new(RepoStatusData.latest_modulesync_version) >
          Gem::Version.new(msync_version)
      )
    else
      status.never_synced = true
    end
  end
end
