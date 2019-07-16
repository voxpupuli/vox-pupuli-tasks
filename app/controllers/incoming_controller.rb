class IncomingController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :logged_in

  def github
    Raven.capture_message('Received hook', extra: params.permit(params.keys).to_h)
  end
end
