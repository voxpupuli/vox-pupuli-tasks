# frozen_string_literal: true

class Github
  def self.client
    @client ||= Octokit::Client.new(
      auto_paginate: true,
      access_token: Rails.application.credentials.github[Rails.env.to_sym][:bot_token]
    )
  end
  
  def self.app
    Octokit::Client.new(
      auto_paginate: true,
      access_token: app_token
    )
  end

  def self.jwt
    private_pem = Rails.application.credentials.github[Rails.env.to_sym][:private_key]
    private_key = OpenSSL::PKey::RSA.new(private_pem)
    
    # Generate the JWT
    payload = {
      # issued at time
      iat: Time.now.to_i,
      # JWT expiration time (10 minute maximum)
      exp: Time.now.to_i + (10 * 60),
      # GitHub App's identifier
      iss: Rails.application.credentials.github[Rails.env.to_sym][:app_id]
    }
    
    jwt = JWT.encode(payload, private_key, "RS256")
  end

  def self.app_token
    app_client =  Octokit::Client.new(
      auto_paginate: true,
      bearer_token: jwt
    )
    installation_id = 1648594
    app_client.create_app_installation_access_token(1648594)[:token]
  end
end
