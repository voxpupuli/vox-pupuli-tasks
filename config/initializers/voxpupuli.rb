# frozen_string_literal: true

# we removed the following modules from our modulesync_config / hide it because they are not
# Puppet modules but match the puppet- pattern
# The modules in the list are broken, unfinished or got migrated
# (yes, that really happens rom time to time)
# ToDo: extend this list with repos that are archived on github
# ToDo: Archive repos that we migrate away
LEGACY_OR_BROKEN_NOBODY_KNOWS = %w[puppet-bacula puppet-nagios_providers puppet-iis puppet-syntax
                                   puppet-blacksmith puppet-mode].freeze

# define some versions that we want to match against
PUPPET_SUPPORT_RANGE = '>= 5.5.8 < 7.0.0'
# Ubuntu 18.04 got released, but Puppet doesn't work yet on it
# https://tickets.puppetlabs.com/browse/PA-1869
# https://github.com/camptocamp/facterdb/pull/82#event-1600066178
UBUNTU_SUPPORT_RANGE = ['14.04', '16.04', '18.04'].freeze
DEBIAN_SUPPORT_RANGE = [8, 9, 10].freeze
CENTOS_SUPPORT_RANGE = [6, 7].freeze
FREEBSD_SUPPORT_RANGE = [11, 12].freeze
