# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :logged_in, only: %i[new create]
  def new; end

  def create
    user = User.from_omniauth(request.env['omniauth.auth'])

    session[:admin] = admin?(user)

    (session[:user_id] = user.id) && redirect_to(root_path) if user.valid?
  end

  def destroy
    reset_session
    redirect_to request.referer
  end

  private

  def admin?(user)
    user_teams = Octokit::Client.new(auto_paginate: true, access_token: user.oauth_token).user_teams
    admin_teams = VOXPUPULI_CONFIG['teams_with_admin_access']

    user_teams.any? do |user_team|
      admin_teams.any? do |admin_team|
        (admin_team['org-login'] == user_team[:organization][:login]) &&
          (admin_team['team-slug'] == user_team[:slug])
      end
    end
  rescue StandardError
    false
  end
end
