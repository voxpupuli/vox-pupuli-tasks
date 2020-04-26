# frozen_string_literal: true

class SyncLabelWorker
  include Sidekiq::Worker

  def perform
    Repository.each do |repository|
      repository.attach_missing_labels
    end
end
