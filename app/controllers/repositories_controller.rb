class RepositoriesController < ApplicationController
  def index
    @repos = Repository.all
  end

  def show
    @repository = Repository.find_by(name: params[:id])
  end
end
