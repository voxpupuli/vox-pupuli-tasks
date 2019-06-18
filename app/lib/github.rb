class Github
  def self.client
    @client ||= Octokit::Client.new(
      auto_paginate: true,
      access_token: Rails.application.credentials.github[Rails.env.to_sym][:bot_token]
    )
  end
end
