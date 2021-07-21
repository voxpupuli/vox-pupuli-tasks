# frozen_string_literal: true

class RefreshPullRequestWorker
  include Sidekiq::Worker

  def self.perform_in(interval, *args)
    this_args = args.tally.to_a
    queue = Sidekiq::Queue.new('default')
    queue.each do |job|
      # use tally. the arrays can contain strings and ints. we cannot call sort on heterogenous arrays
      # see also https://twitter.com/BastelsBlog/status/1311421975827546112
      if (job.args.tally.to_a - this_args).empty? && (job.item['class'] == name)
        Raven.capture_message('Duplicate Job, discarding', extra: { id: id, worker: name })
        return false
      end
    end
    super(interval, args)
  end

  def perform(repo, number)
    pull_request = Github.client.pull_request("voxpupuli/#{repo}", number)
    PullRequest.update_with_github(pull_request)
  end
end
