# frozen_string_literal: true

class Github
  def self.bot
    @bot ||= Octokit::Client.new(
      auto_paginate: true,
      access_token: Rails.application.credentials.github[Rails.env.to_sym][:bot_token]
    )
  end

  def self.client
    Octokit::Client.new(
      auto_paginate: true,
      access_token: app_token['token']
    )
  end

  def self.jwt
    private_pem = Rails.application.credentials.github[Rails.env.to_sym][:private_key]
    private_key = OpenSSL::PKey::RSA.new(private_pem)

    payload = {
      iat: Time.now.to_i,
      exp: Time.now.to_i + (10 * 60),
      iss: Rails.application.credentials.github[Rails.env.to_sym][:app_id]
    }

    JWT.encode(payload, private_key, 'RS256')
  end

  def self.create_app_token
    app_client = Octokit::Client.new(
      auto_paginate: true,
      bearer_token: jwt
    )
    token = app_client.create_app_installation_access_token(1_648_594)

    RedisClient.client.set('app-token', Oj.generate(token.to_h))

    token
  end

  def self.app_token
    token = RedisClient.client.get('app-token')

    return create_app_token unless token

    payload = Oj.load(token)
    if Time.parse(payload['expires_at']).to_i < Time.now.utc.to_i
      create_app_token
    else
      payload
    end
  end
end
