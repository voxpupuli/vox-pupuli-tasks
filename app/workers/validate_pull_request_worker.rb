# frozen_string_literal: true

class ValidatePullRequestWorker
  include Sidekiq::Worker

  def self.perform_async(id)
    this_args = method(__method__).parameters.map do |_, name|
      binding.local_variable_get(name)
    end

    this_args = this_args.tally.to_a
    queue = Sidekiq::Queue.new('default')
    queue.each do |job|
      # use tally. the arrays can contain strings and ints. we cannot call sort on heterogenous arrays
      # see also https://twitter.com/BastelsBlog/status/1311421975827546112
      if (job.args.tally.to_a - this_args).empty? && (job.item['class'] == name)
        Sentry.capture_message('Duplicate Job, discarding', extra: { id: id, worker: name })
        return false
      end
    end
    super(id)
  end

  ##
  # As validation may take a bit more time we do it async.
  # This worker is not meant to hold any logic but only trigger the
  # validation in its asyncronous context.

  def perform(id)
    PullRequest.find(id).validate
  end
end
