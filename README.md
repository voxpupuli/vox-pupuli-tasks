# Vox Pupuli Tasks - The Webapp for community management

## Table of contents

* [Purpose](#purpose)
  * [Reviewing open Pull Requests](#reviewing-open-pull-requests)
  * [Yak shaving Puppet modules](#yak-shaving-puppet-modules)
* [Local Setup](#local-setup)
* [Contribution](#contribution)
* [License](#license)

## Purpose

As a collaborator at [Vox Pupuli](https://voxpupuli.org) we have basically two
different kinds of main tasks:

* Reviewing open Pull Requests
* Yak shaving [Puppet modules](https://forge.puppet.com/puppet)

We currently have a few tools for those jobs:

## Reviewing open Pull Requests

* [https://octobox.io/](https://octobox.io/) is a nice external webinterface to work with github issues and pull requests
* [https://voxpupuli-open-prs.herokuapp.com/](https://voxpupuli-open-prs.herokuapp.com/) is [our own](https://github.com/voxpupuli/open-prs#vox-pupuli-open-prs) Sinatra app to display all pull requests
* GitHub has a nice search function for [pull requests](https://github.com/pulls?q=is%3Aopen+is%3Apr+user%3Avoxpupuli+archived%3Afalse+sort%3Acreated-asc) but also [for issues](https://github.com/issues?q=is%3Aopen+is%3Aissue+user%3Avoxpupuli+archived%3Afalse+sort%3Acreated-asc)
* The [ommunity_management](https://github.com/underscorgan/community_management#community-management) project provides some CLI tools to generate different reports about open pull requests

Collaborators review a lot of code in many pull requests. But there are even
more pull requests that are open but don't need any attention. A collaborator
spends a lot of time to figure out which pull request actually needs attention.

One of the goals of this project is to provide a proper UI that displays
filtered pull requests. Some examples:

It's not required to review code in a pull request if a merge conflict exists.
If the PR is properly labeled, we can exclude it from the UI. The service gets
notifications from GitHub for each activity on a PR. If a conflict appears, a
label will be added. It will also automatically be removed if the conflict
disappears after a rebase.

Instead of dealing with all open PRs over and over, collaborators can spend
their time to reviewing pull requests that actually need it.

Some more examples are documented as [open issues](https://github.com/voxpupuli/vox-pupuli-tasks/issues/), in particular [issue 4](https://github.com/voxpupuli/vox-pupuli-tasks/issues/4)

## Yak shaving Puppet modules

* The [get_all_the_diffs](https://github.com/voxpupuli/modulesync_config/blob/master/bin/get_all_the_diffs) script, which detects inconsistencies in modules

This is the second big tasks for collaborators. Update dependencies in
metadata.json files, allow new Puppet versions, drop legacy operating systems.
There are many many tasks that collaborators do dfrom time to time and this
project tries to make it as easy as possible or even automate stuff where it's
suitable.

## Local Setup

To start the app locally, do (assumes that you've ruby, bundler and yarn
available, also redis needs to be started):

```sh
git clone git@github.com:voxpupuli/vox-pupuli-tasks.git
cd vox-pupuli-tasks
bundle install --jobs $(nproc) --with development test --path vendor/bundle
bundle exec yarn install --frozen-lockfile --non-interactive
export SECRET_KEY_BASE=$(bundle exec rails secret)
bundle exec rails assets:precompile
# somehow generate config/master.key
RAILS_ENV=development bundle exec rails db:migrate
bundle exec foreman start
```

Secrets are stored as an encrypted yaml file. You can edit them by doing:

```sh
bundle exec rails credentials:edit
```

This only works properly if one od the developers sent you the `/config/master.key`
file.

[Foreman](https://rubygems.org/gems/foreman) will take care of the actual rails
application, but it will also start [sidekiq](https://github.com/mperham/sidekiq#sidekiq).

## License

This project is licensed under [GNU Affero General Public License version 3](LICENSE)
