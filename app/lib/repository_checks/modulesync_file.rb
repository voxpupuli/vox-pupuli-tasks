# frozen_string_literal: true

class ModulesyncFile < RepositoryCheckBase
  def perform(repo)
    msync_file = Github.get_file(repo.full_name, '.msync.yml')

    if msync_file
      repo.never_synced = false
      msync_version = YAML.safe_load(msync_file)['modulesync_config_version']

      repo.needs_another_sync = (
        Gem::Version.new(RepoStatusData.latest_modulesync_version) >
          Gem::Version.new(msync_version)
      )
    else
      repo.never_synced = true
    end
  end
end
