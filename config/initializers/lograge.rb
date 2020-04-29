# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = Rails.env.production?

  config.lograge.ignore_actions = ['IncomingController#github', 'IncomingController#travis']
end
