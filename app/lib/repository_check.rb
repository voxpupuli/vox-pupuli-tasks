# frozen_string_literal: true

class RepositoryCheck
  def self.init
    REPOSITORY_STATUS_CHECKS << name
  end

  def self.load_checks
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
end
