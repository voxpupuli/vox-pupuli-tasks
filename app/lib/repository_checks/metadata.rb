# frozen_string_literal: true

class Metadata < RepositoryCheckBase
  def perform
    metadata = Github.get_file(repo.full_name, 'metadata.json')

    if metadata
      submit_result :metadata_valid, true
    else
      submit_result :metadata_valid, false
      return
    end

    metadata = Oj.load(metadata)

    check_puppet_version(metadata)

    if metadata['operatingsystem_support']
      submit_result :with_operatingsystem_support, true
    else
      submit_result :with_operatingsystem_support, false
      return
    end

    check_operating_system_support(metadata)
  end

  def check_operating_system_support(metadata)
    metadata['operatingsystem_support'].each do |os|
      os_type = os['operatingsystem']

      supported_versions = calculate_supported_versions(os_type, os)
      support_range = calculate_support_range(os_type)

      submit_result("supports_only_current_#{os_type.downcase}",
                    supported_versions.min > support_range.min)
      submit_result("supports_latest_#{os_type.downcase}",
                    supported_versions.max == support_range.max)
    rescue NameError
      next
    end
  end

  def calculate_support_range(os_type)
    if os_type == 'Ubuntu'
      "#{os_type.upcase}_SUPPORT_RANGE".constantize
    else
      "#{os_type.upcase}_SUPPORT_RANGE".constantize.all_i
    end
  end

  def calculate_supported_versions(os_type, os)
    if os_type == 'Ubuntu'
      os['operatingsystemrelease']
    else
      os['operatingsystemrelease'].all_i
    end
  end

  def check_puppet_version(metadata)
    version_requirement = metadata['requirements'][0]['version_requirement']

    submit_result :correct_puppet_version_range, PUPPET_SUPPORT_RANGE == version_requirement
    submit_result :with_puppet_version_range, true
  rescue NoMethodError
    submit_result :with_puppet_version_range, false
  end
end
