# frozen_string_literal: true

VOXPUPULI_CONFIG = YAML.load_file('config/voxpupuli.yml')

LEGACY_OR_BROKEN_NOBODY_KNOWS = VOXPUPULI_CONFIG['legacy_or_broken_nobody_knows']
# define some versions that we want to match against
PUPPET_SUPPORT_RANGE = VOXPUPULI_CONFIG['puppet_support_range']
# Ubuntu 18.04 got released, but Puppet doesn't work yet on it
# https://tickets.puppetlabs.com/browse/PA-1869
# https://github.com/camptocamp/facterdb/pull/82#event-1600066178

UBUNTU_SUPPORT_RANGE  = VOXPUPULI_CONFIG.dig('support_ranges', 'ubuntu')
DEBIAN_SUPPORT_RANGE  = VOXPUPULI_CONFIG.dig('support_ranges', 'debian')
CENTOS_SUPPORT_RANGE  = VOXPUPULI_CONFIG.dig('support_ranges', 'centos')
FREEBSD_SUPPORT_RANGE = VOXPUPULI_CONFIG.dig('support_ranges', 'freebsd')
FEDORA_SUPPORT_RANGE  = VOXPUPULI_CONFIG.dig('support_ranges', 'fedora')
