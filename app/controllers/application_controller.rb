class ApplicationController < ActionController::Base
  include CacheHelper

  helper_method :current_user, :github

  def current_user
    session[:user_id].nil? ? nil : User.find(session[:user_id])
  end

  def github
    if current_user
      Octokit::Client.new(auto_paginate: true, access_token: current_user.oauth_token)
    else
      Octokit::Client.new(auto_paginate: true)
    end
  end
end
