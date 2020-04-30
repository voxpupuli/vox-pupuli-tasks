# frozen_string_literal: true

class RepoStatusWorker
  include Sidekiq::Worker

  def refresh_managed_modules
    data = Github.get_file('voxpupuli/modulesync_config', 'managed_modules.yml')
    RepoStatusData.modulesync_repos = begin
                                        YAML.safe_load(data)
                                      rescue StandardError
                                        []
                                      end
  end

  def refresh_plumbing_modules
    data = Github.get_file('voxpupuli/plumbing', 'share/modules')
    RepoStatusData.plumbing_modules = begin
                                        data.split("\n")
                                      rescue StandardError
                                        []
                                      end
  end

  def refresh_forge_releases
    PuppetForge.user_agent = 'VoxPupuli/Vox Pupuli Tasks'
    RepoStatusData.forge_releases = begin
                                      vp = PuppetForge::User.find('puppet')
                                      vp.modules.unpaginated.map(&:slug)
                                    rescue StandardError
                                      []
                                    end
  end

  def refresh_latest_modulesync_version
    RepoStatusData.latest_modulesync_version = begin
                                                 Github
                                                   .client
                                                   .tags('voxpupuli/modulesync_config')
                                                   .first
                                                   .name
                                               rescue StandardError
                                                 nil
                                               end
  end

  def perform
    refresh_plumbing_modules
    refresh_managed_modules
    refresh_latest_modulesync_version

    Repositories.each(&:update_todos)
  end
end
