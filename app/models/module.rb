# a module represents a release on https://forge.puppet.com/
class Module < ApplicationRecord
  belongs_to :repository
end
