class DashboardController < ApplicationController
  def show
    @data = JSON.parse(RedisClient.client.get('repo_status_data'))
  end
end