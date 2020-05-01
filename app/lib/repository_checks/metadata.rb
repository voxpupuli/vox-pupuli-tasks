# frozen_string_literal: true

class Metadata < RepositoryCheckBase
  attr_reader :repo, :status

  def perform(repo, status)
    @repo = repo
    @status = status

    metadata = Github.get_file(repo.full_name, 'metadata.json')

    if metadata
      status.broken_metadata = false
    else
      status.broken_metadata = true
      return
    end

    metadata = Oj.load(metadata)

    check_puppet_version(metadata)

    if metadata['operatingsystem_support'].nil?
      status.without_operatingsystems_support = true
      return
    else
      status.without_operatingsystems_support = false
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

      status.send(
        "supports_eol_#{os_type.downcase}=",
        supported_versions.min < support_range.min
      )

      status.send(
        "doesnt_support_latest_#{os_type.downcase}=",
        supported_versions.max < support_range.max
      )
    rescue NameError
      next
    end
  end

  def check_puppet_version(metadata)
    version_requirement = metadata['requirements'][0]['version_requirement']

    status.incorrect_puppet_version_range = PUPPET_SUPPORT_RANGE != version_requirement
    status.without_puppet_version_range = false
  rescue NoMethodError
    status.without_puppet_version_range = true
  end
end
