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
  task :rubocop do
    raise 'rubocop is not available in this installation'
  end
end

desc 'Display the list of available rake tasks'
task :help do
  system('rake -T')
end
