class RedisClient
  def self.client
    @client ||= Redis.new(Rails.application.credentials.redis[Rails.env.to_sym])
  end
end
