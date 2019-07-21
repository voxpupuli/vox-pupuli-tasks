class IncomingController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :logged_in

  def github
    # parse the JSON payload, that we get as string, to a hash
    useable_body = JSON.parse(request.body.read).to_h

    Raven.capture_message('Received hook', extra: useable_body)
  end
end
