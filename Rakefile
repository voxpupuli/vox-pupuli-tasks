# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    # These make the rubocop experience maybe slightly less terrible
    task.options = ['-D', '-S', '-E']
  end
rescue LoadError
  desc 'rubocop is not available in this installation'
  task rubocop: :environment do
    raise 'rubocop is not available in this installation'
  end
end

desc 'Display the list of available rake tasks'
task help: :environment do
  system('rake -T')
end

begin
  require 'github_changelog_generator/task'

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file."
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog]
    config.user = 'voxpupuli'
    config.project = 'vox-pupuli-tasks'
    config.future_release = 'v1.0.1'
  end
rescue LoadError # rubocop:disable Lint/SuppressedException
end
