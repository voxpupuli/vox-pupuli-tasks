class RepositoryCheck
  def self.init
    REPOSITORY_STATUS_CHECKS << name
  end

  def self.load_checks
    Dir[File.join("#{Rails.root}/app/lib/repository_checks", "*.rb")].each do |file|
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