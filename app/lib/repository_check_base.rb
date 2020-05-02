# frozen_string_literal: true

class RepositoryCheckBase
  attr_reader :status, :repo

  def self.init
    REPOSITORY_STATUS_CHECKS << name
  end

  def self.register_checks
    Dir[Rails.root.join('app/lib/repository_checks/*.rb')].sort.each do |file|
      require file
      clazz = File.basename(file, '.rb').camelcase.constantize

      next unless valid?(clazz)

      clazz.init
    end
  end

  def self.valid?(clazz)
    clazz.method_defined?('perform') && (clazz < self)
  end

  def initialize(repo, status)
    @repo = repo
    @status = status
  end

  def submit_result(name, result)
    status.checks[name.to_s] = result
    status.save
  end
end
