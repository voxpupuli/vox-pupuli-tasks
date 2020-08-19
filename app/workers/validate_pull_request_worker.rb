# frozen_string_literal: true

class ValidatePullRequestWorker
  include Sidekiq::Worker

  def self.perform_async(id)
    this_args = method(__method__).parameters.map do |_, name|
      binding.local_variable_get(name)
    end

    queue = Sidekiq::Queue.new('default')
    queue.each do |job|
      if (job.args.sort == this_args.sort) && (job.item['class'] == name)
        Raven.capture_message('Duplicate Job, discarding', extra: { id: id, worker: name })
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
