# frozen_string_literal: true

class ModulesyncFile < RepositoryCheckBase
  def perform
    msync_file = Github.get_file(repo.full_name, '.msync.yml')

    if msync_file
      submit_result :synced, true
      msync_version = YAML.safe_load(msync_file)['modulesync_config_version']

      submit_result :latest_modulesync = (
        Gem::Version.new(RepoStatusData.latest_modulesync_version) ==
          Gem::Version.new(msync_version)
      )
    else
      submit_result :synced, false
    end
  end
end
