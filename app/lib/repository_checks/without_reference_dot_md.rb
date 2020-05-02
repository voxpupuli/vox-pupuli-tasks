# frozen_string_literal: true

class WithoutReferenceDotMd < RepositoryCheckBase
  def perform
    submit_result :reference_dot_md = Github.get_file(repo.full_name, 'REFERENCE.md')
  end
end
