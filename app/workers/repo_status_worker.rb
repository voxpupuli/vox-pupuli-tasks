# frozen_string_literal: true

class RepoStatusWorker
  include Sidekiq::Worker

  def save_data_to_redis(data)
    redis = RedisClient.client

    redis.set('repo_status_time', Time.now.to_i)
    redis.set('repo_status_data', data.to_h.to_json)
  end

  # Categorizes repository based on their locally cached information
  # implements https://github.com/voxpupuli/modulesync_config/blob/master/bin/get_all_the_diffs
  # TODO: clean up stuff and make it less shitty
  def perform
    repos = Repository.pluck(:name)
    data = OpenStruct.new

    # get all managed modules from our modulesync_config
    modulesync_repos = YAML.safe_load(open('https://raw.githubusercontent.com/voxpupuli/modulesync_config/master/managed_modules.yml').read)

    # get all modules we have in plumbing
    plumbing_modules = YAML.safe_load(
      open('https://raw.githubusercontent.com/voxpupuli/plumbing/master/share/modules')
    ).split(' ')

    # get all modules that need to added to plumbing
    data.missing_in_plumbing = repos.reject { |repo| plumbing_modules.include?(repo) }

    # get all modules that we have on github but are currently not managed by modulesync_config
    data.not_synced_repos = repos.reject { |repo| modulesync_repos.include?(repo) }

    # get all modules that require a modulesync
    data.really_need_an_initial_modulesync = data.not_synced_repos.reject do |repo|
      LEGACY_OR_BROKEN_NOBODY_KNOWS.include?(repo)
    end

    # get all forge releases
    PuppetForge.user_agent = 'VoxPupuli/Vox Pupuli Tasks'
    vp = PuppetForge::User.find('puppet')
    forge_releases = vp.modules.unpaginated.map(&:slug)

    # get all modules that are in modulesync_config but not released
    data.unreleased_modules = modulesync_repos.reject { |repo| forge_releases.include?(repo) }

    # get all modules we own but are unreleased
    data.really_unreleased_modules = repos.reject { |repo| forge_releases.include?(repo) }

    # get all modules that really need an initial release
    data.really_need_an_inital_release = data.really_unreleased_modules.reject do |repo|
      LEGACY_OR_BROKEN_NOBODY_KNOWS.include?(repo)
    end

    latest_release = Github.client.tags('voxpupuli/modulesync_config').first.name

    # get all the content of all .msync.yml, .sync.yml and metadata.json files
    data.modules_that_were_added_but_never_synced = []
    data.modules_that_have_missing_secrets = []
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
        puts("something is broken with #{repo} and https://raw.githubusercontent.com/voxpupuli/" |
             "#{repo}/master/metadata.json")
        next
      end
      metadatas[repo] = JSON.parse(response)
    end

    # get the current modulesync version for all repos
    versions = {}
    msyncs.each do |repo, msync|
      versions[repo] = msync['modulesync_config_version']
    end

    # TODO: get all modules that dont have a secret in .sync.yml

    # TODO: get all modules with outdated Puppet versions
    data.modules_without_puppet_version_range = []
    data.modules_with_incorrect_puppet_version_range = []
    data.modules_without_operatingsystems_support = []
    data.supports_eol_ubuntu = []
    data.supports_eol_debian = []
    data.supports_eol_centos = []
    data.doesnt_support_latest_ubuntu = []
    data.doesnt_support_latest_debian = []
    data.doesnt_support_latest_centos = []

    metadatas.each do |repo, metadata|
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
          end
        end
      rescue NoMethodError
        data.modules_without_operatingsystems_support << repo
      end
    end

    # we have a list of CentOS and RedHat in this array, we need to clean it up
    data.supports_eol_centos.sort!.uniq!
    data.doesnt_support_latest_centos.sort!.uniq!

    # get all repos that are on an outdated version of modulesync_config
    data.need_another_sync = []
    versions.each do |repo|
      # index 0 is the module name, index 1 is the used modulesync_config version
      if Gem::Version.new(latest_release) >= Gem::Version.new(repo[1])
        data.need_another_sync << repo[0]
      end
    end

    save_data_to_redis(data)
  end
end
