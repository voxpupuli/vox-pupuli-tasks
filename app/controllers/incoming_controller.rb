class IncomingController < ApplicationController
  def github
    Raven.capture_message('Received hook') 
  end
end