# frozen_string_literal: true

VOXPUPULI_CONFIG = YAML.load_file('config/voxpupuli.yml')

LEGACY_OR_BROKEN_NOBODY_KNOWS = VOXPUPULI_CONFIG['legacy_or_broken_nobody_knows']
# define some versions that we want to match against
PUPPET_SUPPORT_RANGE = VOXPUPULI_CONFIG['puppet_support_range']

UBUNTU_SUPPORT_RANGE  = VOXPUPULI_CONFIG.dig('support_ranges', 'ubuntu')
DEBIAN_SUPPORT_RANGE  = VOXPUPULI_CONFIG.dig('support_ranges', 'debian')
CENTOS_SUPPORT_RANGE  = VOXPUPULI_CONFIG.dig('support_ranges', 'centos')
FREEBSD_SUPPORT_RANGE = VOXPUPULI_CONFIG.dig('support_ranges', 'freebsd')
FEDORA_SUPPORT_RANGE  = VOXPUPULI_CONFIG.dig('support_ranges', 'fedora')

REPOSITORY_STATUS_CHECKS = []

RepositoryCheckBase.register_checks
