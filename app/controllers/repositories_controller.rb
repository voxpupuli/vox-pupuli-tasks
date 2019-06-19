class RepositoriesController < ApplicationController
  def index
    @repos = Repository.all
  end

  def show; end
end