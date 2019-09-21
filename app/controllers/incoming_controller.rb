# frozen_string_literal: true

class IncomingController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :logged_in

  ##
  #  Parse the whole payload from Github and hand it over to the GithubEvent handler
  def github
    payload = request.body.read
    useable_body = JSON.parse(payload).to_h

    verify_signature(payload)

    # For debug purposes we currently log the requets into Sentry
    # TODO: Remove this line since the GithubEvent handler reports unknown events.
    Raven.capture_message('Received hook', extra: useable_body)

    GithubEvent.new(useable_body, request.headers['X-GitHub-Event'])
  end

  private

  def verify_signature(payload)
    webhook_secret = Rails.application.credentials.github[Rails.env.to_sym][:webhook_secret]
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),
                                                  webhook_secret,
                                                  payload)

    return if Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])

    Raven.capture_message('Invalid webhook signature')
  end
end
