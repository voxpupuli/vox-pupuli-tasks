class PullRequest < ApplicationRecord
  belongs_to :repository
  has_and_belongs_to_many :labels
end
