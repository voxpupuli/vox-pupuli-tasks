# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @data = begin
              JSON.parse(RedisClient.client.get('repo_status_data').to_s)
            rescue JSON::ParserError
              nil
            end
    @last_sync = Time.zone.at(RedisClient.client.get('repo_status_time').to_i)
  end

  def about; end
end
