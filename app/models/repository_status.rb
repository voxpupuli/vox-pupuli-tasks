# frozen_string_literal: true

class RepositoryStatus < ApplicationRecord
  belongs_to :repository

  after_create :perform_checks

  def name
    @name ||= repository.name
  end

  def full_name
    @full_name ||= repository.full_name
  end

  def perform_checks
    REPOSITORY_STATUS_CHECKS.each do |check|
      check.constantize.new.perform(repository, self)
    end
  end
end
