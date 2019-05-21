class DashboardController < ApplicationController
  def show
    @repos = Repository.all
    @repo_list = @repos.pluck(:name)
  end
end