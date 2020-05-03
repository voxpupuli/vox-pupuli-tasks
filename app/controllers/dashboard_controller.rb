# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @repositories = Repository.all
    @statuses = @repositories.map(&:current_status)
  end

  def about; end
end
