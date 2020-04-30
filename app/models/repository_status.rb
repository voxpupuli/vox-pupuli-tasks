# frozen_string_literal: true

class RepositoryStatus < ApplicationRecord
  belongs_to :repository

  after_create :perform_checks

  def name
    @name ||= repository.name
  end

  def full_name
    @full_name ||= repository.full_name
  end

  def perform_checks
    self.missing_in_plumbing = !RepoStatusData.plumbing_modules.include?(name)

    self.need_initial_modulesync = (!RepoStatusData.modulesync_repos.include?(name) &&
                                                  !LEGACY_OR_BROKEN_NOBODY_KNOWS.include?(name))

    self.need_initial_release = (!RepoStatusData.forge_releases.include?(name) &&
                                                  !LEGACY_OR_BROKEN_NOBODY_KNOWS.include?(name))

    self.without_reference_dot_md = !Github.get_file(full_name, 'REFERENCE.md')
    self.added_but_never_synced = !Github.get_file(full_name, '.msync.yml')

    self.missing_in_modulesync_repo = !RepoStatusData.modulesync_repos.include?(name)

    msync_file = Github.get_file(full_name, '.msync.yml')
    if msync_file
      self.never_synced = false
      msync_version = YAML.safe_load(msync_file)['modulesync_config_version']

      self.needs_another_sync = (
        Gem::Version.new(RepoStatusData.latest_modulesync_version) >
          Gem::Version.new(msync_version)
      )
    else
      self.never_synced = true
    end

    self.missing_secrets = !Github.get_file(full_name, '.sync.yml')

    metadata = Github.get_file(full_name, 'metadata.json')
    if metadata
      check_operating_system(Oj.load(metadata))
    else
      self.broken_metadata = true
    end

    true
  end

  def check_operating_system(metadata)
    begin
      version_requirement = metadata['requirements'][0]['version_requirement']

      self.incorrect_puppet_version_range = PUPPET_SUPPORT_RANGE != version_requirement
    rescue NoMethodError
      self.without_puppet_version_range = true
    end

    if metadata['operatingsystem_support'].nil?
      self.without_operatingsystems_support = true
      return
    end

    metadata['operatingsystem_support'].each do |os|
      os_type = os['operatingsystem']

      if os_type == 'Ubuntu'
        support_range = "#{os_type.upcase}_SUPPORT_RANGE".constantize
        supported_versions = os['operatingsystemrelease']
      else
        support_range = "#{os_type.upcase}_SUPPORT_RANGE".constantize.all_i
        supported_versions = os['operatingsystemrelease'].all_i
      end

      send(
        "supports_eol_#{os_type.downcase}=",
        supported_versions.min < support_range.min
      )

      send(
        "doesnt_support_latest_#{os_type.downcase}=",
        supported_versions.max < support_range.max
      )
    rescue NameError
      next
    end
  end
end
