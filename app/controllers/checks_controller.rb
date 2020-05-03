# frozen_string_literal: true

class ChecksController < ApplicationController
  def show
    @repositories = Repository.all
    @check_name = params[:check_name]
  end
end
