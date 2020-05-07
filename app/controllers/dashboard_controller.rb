# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @repositories = Repository.all
    @statuses = @repositories.map(&:current_status)
    @last_status = RepositoryStatus.last
  end

  def about; end
end
