class IncomingController < ApplicationController
  skip_before_action :verify_authenticity_token

  def github
    Raven.capture_message('Received hook') 
  end
end