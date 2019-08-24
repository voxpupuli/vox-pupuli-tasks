# frozen_string_literal: true

class Label < ApplicationRecord
  has_and_belongs_to_many :pull_requests

  # TODO: Find out how to manage predefined labels
  def self.needs_rebase
    find_or_create_by(name: 'merge-conflicts', color: '207de5')
  end
end
