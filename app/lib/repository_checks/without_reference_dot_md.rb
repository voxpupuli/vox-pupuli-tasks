# frozen_string_literal: true

class WithoutReferenceDotMd < RepositoryCheckBase
  def perform(repo)
    repo.without_reference_dot_md = !Github.get_file(repo.full_name, 'REFERENCE.md')
  end
end
