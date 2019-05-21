module CacheHelper
  SEED        = 'Eibae1Ox'.freeze
  APP_NAME    = Rails.application.class.parent_name
  PREFIX      = "#{APP_NAME}::cache::#{SEED}".freeze
  DEFAULT_TTL = 6.hours

  def cached_data(name: nil, ttl: DEFAULT_TTL, id: nil, key: "#{PREFIX}::#{name}#{id}", fresh: false, &values)
    logger.info "Requesting #{name}"
    if !fresh && (cached_values = redis.get(key))
      logger.info 'Found cached data'
      Oj.load cached_values
    else
      logger.info 'No cache found'

      value = instance_exec(&values)
      redis.setex key, ttl, Oj.dump(value)

      logger.info 'Refresh done..'
      logger.debug("Cached '#{name}' for #{ttl} seconds at'#{key}'")

      value
    end
  end

  def cache_ttl(id: nil, name: nil, key: "#{PREFIX}::#{name}#{id}")
    redis.ttl key
  end

  def flush(key: nil)
    if key.to_s == 'all'
      keys = redis.keys "#{PREFIX}::*"
      logger.debug "Going to delete #{keys.inspect}"
      keys.each do |redis_key|
        logger.info "Removing #{redis_key}"
        redis.del redis_key
      end
      keys.count
    else
      logger.info "Removing #{key}"
      redis.del key
      1
    end
  end

  def cache_count
    redis.keys("#{PREFIX}::*").count
  end

  private

  def redis
    config = Rails.application.credentials.redis[Rails.env.to_sym]

    @redis ||= Redis.new(config)
  end

  def logger
    @logger ||= Logger.new('log/cache.log')
  end

end
