# frozen_string_literal: true

# enable logging to elasticsearch
if Rails.application.credentials.elasticsearch
  SemanticLogger.add_appender(
    appender: :elasticsearch,
    url: Rails.application.credentials.elasticsearch[:host]
  )
end
