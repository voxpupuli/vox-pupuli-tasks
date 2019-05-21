opts = { scope: 'read:user,public_repo' }

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :github, Rails.application.credentials.github[Rails.env.to_sym][:client_id], Rails.application.credentials.github[Rails.env.to_sym][:client_secret], opts
end
