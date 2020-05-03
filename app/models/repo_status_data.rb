# frozen_string_literal: true

class RepoStatusData < RailsSettings::Base
  cache_prefix { 'v1' }

  field :modulesync_repos,          type: :array, default: []
  field :plumbing_modules,          type: :array, default: []
  field :forge_releases,            type: :array, default: []
  field :latest_modulesync_version, type: :string
end
