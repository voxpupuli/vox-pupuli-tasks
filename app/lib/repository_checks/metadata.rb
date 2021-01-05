# frozen_string_literal: true

class Metadata < RepositoryCheckBase
  def perform
    raw_metadata = Github.get_file(repo.full_name, 'metadata.json')

    if not raw_metadata
      submit_result :metadata_valid, false
      return
    end

    begin
      metadata = PuppetMetadata::Metadata.new(Oj.load(raw_metadata))
    rescue PuppetMetadata::InvalidMetadataException
      submit_result :metadata_valid, false
      return
    end

    submit_result :metadata_valid, true

    check_puppet_version(metadata)

    # TODO: Not entirely the same. Is it also useful? extlib is functions only
    # and shouldn't list any OS
    if metadata.operatingsystems.any?
      submit_result :with_operatingsystem_support, true
    else
      submit_result :with_operatingsystem_support, false
      return
    end

    check_operating_system_support(metadata)
  end

  def check_operating_system_support(metadata)
    metadata.operatingsystems.each do |os, releases|
      submit_result("supports_only_current_#{os.downcase}",
                    releases&.any? && PuppetMetadata::OperatingSystem.eol?(os, releases.first))

      # TODO latest_release can be nil
      submit_result("supports_latest_#{os.downcase}",
                    releases&.include?(PuppetMetadata::OperatingSystem.latest_release))
    end
  end

  def check_puppet_version(metadata)
    version_requirement = metadata.requirements['puppet']
    if version_requirement
      submit_result :correct_puppet_version_range, PUPPET_SUPPORT_RANGE == version_requirement.to_s
      submit_result :with_puppet_version_range, true
    else
      submit_result :with_puppet_version_range, false
    end
  end
end
