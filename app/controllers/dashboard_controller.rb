class DashboardController < ApplicationController
  def show
    @data = JSON.parse(RedisClient.client.get('repo_status_data'))
    @last_sync = Time.at(RedisClient.client.get('repo_status_time').to_i)
  end
end