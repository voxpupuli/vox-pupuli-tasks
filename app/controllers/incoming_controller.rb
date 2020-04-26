# frozen_string_literal: true

class IncomingController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :logged_in

  ##
  #  Parse the whole payload from Github and hand it over to the GithubEvent handler
  def github
    # TODO: verify the payload
    payload = request.body.read
    useable_body = JSON.parse(payload).to_h

    verify_signature(payload)

    GithubEvent.new(useable_body, request.headers['X-GitHub-Event'])
  end

  ##
  # Parse the whole payload from travis and hand it over to the TravisEvent handler
  def travis
    # TODO: verify the payload
    # https://github.com/travis-ci/webhook-signature-verifier/blob/master/lib/webhook-signature-verifier.rb#L40
    # https://docs.travis-ci.com/user/notifications/#verifying-webhook-requests
    payload = request.body.read
    useable_body = JSON.parse(payload).to_h
    TravisEvent.new(useable_body)
  end

  private

  def verify_signature(payload)
    webhook_secret = Rails.application.credentials.github[Rails.env.to_sym][:webhook_secret]
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),
                                                  webhook_secret,
                                                  payload)

    return if Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])

    Raven.capture_message('Invalid webhook signature')
    halt 500, 'invalid signature'
  end
end
