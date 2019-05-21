class RepositoriesController < ApplicationController
  def index
    repos = filter(Repository.all)
    repos = sort(repos)

    repos = if params['_limit']
              repos.page(params['_page']).per(params['_limit'])
            else
              repos.count
            end


    render json: repos
  end

  private

  def filter(repos)
    return repos unless params['q']

    repos.where('name LIKE :query', query: "%#{params['q']}%")
  end

  def sort(repos)
    return repos unless params['_order'] && params['_order'] != 'null'

    repos.order(params['_sort'] => params['_order'])
  end
end