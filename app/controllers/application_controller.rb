# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include CacheHelper

  before_action :logged_in, only: []

  helper_method :current_user, :github

  def current_user
    session[:user_id].nil? ? nil : User.find_by(id: session[:user_id])
  end

  def github
    if current_user
      Octokit::Client.new(auto_paginate: true, access_token: current_user.oauth_token)
    else
      Octokit::Client.new(auto_paginate: true)
    end
  end

  def logged_in
    redirect_to(sessions_new_path) && return unless current_user
  end
end
