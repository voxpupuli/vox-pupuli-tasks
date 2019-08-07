opts = { scope: 'read:user,public_repo' }

# TODO: this is a workaround to build the assets. Define how this will raise in real production
if Rails.application.credentials.github
  Rails.application.config.middleware.use OmniAuth::Builder do
	   provider(:github,
             Rails.application.credentials.github[Rails.env.to_sym][:client_id],
             Rails.application.credentials.github[Rails.env.to_sym][:client_secret],
             opts)
  end
end
