# frozen_string_literal: true

class RepoStatusWorker
  include Sidekiq::Worker

  def save_data_to_redis(data)
    redis = RedisClient.client

    redis.set('repo_status_time', Time.now.to_i)
    redis.set('repo_status_data', data.to_h.to_json)
  end

  def validate_metadatas(data, metadatas)
    # TODO: get all modules that dont have a secret in .sync.yml
    data.modules_without_puppet_version_range = []
    data.modules_with_incorrect_puppet_version_range = []
    data.modules_without_operatingsystems_support = []
    data.supports_eol_ubuntu = []
    data.supports_eol_debian = []
    data.supports_eol_centos = []
    data.supports_eol_freebsd = []
    data.supports_eol_fedora = []
    data.doesnt_support_latest_ubuntu = []
    data.doesnt_support_latest_debian = []
    data.doesnt_support_latest_centos = []
    data.doesnt_support_latest_freebsd = []
    data.doesnt_support_latest_fedora = []

    metadatas.each do |repo, metadata|
      logger.info "RepoStatusWorker: starting validate_metadatas method for #{repo}"
      # check if Puppet version range is correct
      begin
        version_requirement = metadata['requirements'][0]['version_requirement']
        if PUPPET_SUPPORT_RANGE != version_requirement
          data.modules_with_incorrect_puppet_version_range << repo
        end
      # it's possible that the version range isn't present at all in the metadata.json
      rescue NoMethodError
        data.modules_without_puppet_version_range << repo
      end

      # check Ubuntu range
      begin
        metadata['operatingsystem_support'].each do |os|
          case os['operatingsystem']
          when 'Ubuntu'
            if os['operatingsystemrelease'].min < UBUNTU_SUPPORT_RANGE.min
              data.supports_eol_ubuntu << repo
            end
            if os['operatingsystemrelease'].max < UBUNTU_SUPPORT_RANGE.max
              data.doesnt_support_latest_ubuntu << repo
            end
          when 'Debian'
            if os['operatingsystemrelease'].all_i.min < DEBIAN_SUPPORT_RANGE.all_i.min
              data.supports_eol_debian << repo
            end
            if os['operatingsystemrelease'].all_i.max < DEBIAN_SUPPORT_RANGE.all_i.max
              data.doesnt_support_latest_debian << repo
            end
          when 'CentOS', 'RedHat'
            if os['operatingsystemrelease'].all_i.min < CENTOS_SUPPORT_RANGE.all_i.min
              data.supports_eol_centos << repo
            end
            if os['operatingsystemrelease'].all_i.max < CENTOS_SUPPORT_RANGE.all_i.max
              data.doesnt_support_latest_centos << repo
            end
          when 'FreeBSD'
            if os['operatingsystemrelease'].all_i.min < FREEBSD_SUPPORT_RANGE.all_i.min
              data.supports_eol_freebsd << repo
            end
            if os['operatingsystemrelease'].all_i.max < FREEBSD_SUPPORT_RANGE.all_i.max
              data.doesnt_support_latest_freebsd << repo
            end
          when 'Fedora'
            if os['operatingsystemrelease'].all_i.min < FEDORA_SUPPORT_RANGE.all_i.min
              data.supports_eol_fedora << repo
            end
            if os['operatingsystemrelease'].all_i.max < FEDORA_SUPPORT_RANGE.all_i.max
              data.doesnt_support_latest_fedora << repo
            end
          end
        end
      rescue NoMethodError
        data.modules_without_operatingsystems_support << repo
      end
    end
    data
  end

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

  # Categorizes repository based on their locally cached information
  # implements https://github.com/voxpupuli/modulesync_config/blob/master/bin/get_all_the_diffs
  # TODO: clean up stuff and make it less shitty
  def perform
    logger.info 'RepoStatusWorker: starting perform method'

    refresh_plumbing_modules
    refresh_managed_modules

    modulesync_repos = RepoStatusData.modulesync_repos

    data = OpenStruct.new

    latest_release = Github.client.tags('voxpupuli/modulesync_config').first.name

    # get all the content of all .msync.yml, .sync.yml and metadata.json files
    data.modules_that_were_added_but_never_synced = []
    data.modules_that_have_missing_secrets = []
    data.modules_without_reference_dot_md = []
    msyncs = {}
    syncs = {}
    metadatas = {}

    modulesync_repos.each do |repo|
      begin
        response = open("https://raw.githubusercontent.com/voxpupuli/#{repo}/master/.msync.yml")
      rescue OpenURI::HTTPError
        data.modules_that_were_added_but_never_synced << repo
        next
      end
      msyncs[repo] = YAML.safe_load(response)
      begin
        response = open("https://raw.githubusercontent.com/voxpupuli/#{repo}/master/.sync.yml")
      rescue OpenURI::HTTPError
        data.modules_that_have_missing_secrets << repo
        next
      end
      syncs[repo] = YAML.safe_load(response)
      begin
        response = open("https://raw.githubusercontent.com/voxpupuli/#{repo}/master/metadata.json")
      rescue OpenURI::HTTPError
        Rails.logger.error("something is broken with #{repo} and " \
          "https://raw.githubusercontent.com/voxpupuli/#{repo}/master/metadata.json")
        next
      end
      metadatas[repo] = JSON.parse(response.string)
    end

    # get the current modulesync version for all repos
    versions = {}
    msyncs.each do |repo, msync|
      versions[repo] = msync['modulesync_config_version']
    end

    data = validate_metadatas(data, metadatas)

    # we have a list of CentOS and RedHat in this array, we need to clean it up
    data.supports_eol_centos.sort!.uniq!
    data.doesnt_support_latest_centos.sort!.uniq!

    # get all repos that are on an outdated version of modulesync_config
    data.need_another_sync = []
    versions.each do |repo|
      # index 0 is the module name, index 1 is the used modulesync_config version
      if Gem::Version.new(latest_release) > Gem::Version.new(repo[1])
        data.need_another_sync << repo[0]
      end
    end

    save_data_to_redis(data)
  end
end
