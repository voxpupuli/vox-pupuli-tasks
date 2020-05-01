# frozen_string_literal: true

class Metadata < RepositoryCheckBase
  def perform(repo)
    metadata = Github.get_file(full_name, 'metadata.json')

    repo.broken_metadata = true && return unless metadata

    metadata = Oj.load(metadata)

    check_puppet_version(metadata)

    if metadata['operatingsystem_support'].nil?
      repo.without_operatingsystems_support = true
      return
    end

    check_operating_system_support(metadata)
  end

  def check_operating_system_support(metadata)
    metadata['operatingsystem_support'].each do |os|
      os_type = os['operatingsystem']

      if os_type == 'Ubuntu'
        support_range = "#{os_type.upcase}_SUPPORT_RANGE".constantize
        supported_versions = os['operatingsystemrelease']
      else
        support_range = "#{os_type.upcase}_SUPPORT_RANGE".constantize.all_i
        supported_versions = os['operatingsystemrelease'].all_i
      end

      repo.send(
        "supports_eol_#{os_type.downcase}=",
        supported_versions.min < support_range.min
      )

      repo.send(
        "doesnt_support_latest_#{os_type.downcase}=",
        supported_versions.max < support_range.max
      )
    rescue NameError
      next
    end
  end

  def check_puppet_version(metadata)
    version_requirement = metadata['requirements'][0]['version_requirement']

    reop.incorrect_puppet_version_range = PUPPET_SUPPORT_RANGE != version_requirement
  rescue NoMethodError
    repo.without_puppet_version_range = true
  end
end
