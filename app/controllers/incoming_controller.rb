class IncomingController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :logged_in

  ##
  #  Parse the whole payload from Github and hand it over to the GithubEvent handler
  def github
    useable_body = JSON.parse(request.body.read).to_h

    # For debug purposes we currently log the requets into Sentry
    # TODO: Remove this line since the GithubEvent handler reports unknown events.
    Raven.capture_message('Received hook', extra: useable_body)

    GithubEvent.new(useable_body, request.headers['X-GitHub-Event'])
  end
end
