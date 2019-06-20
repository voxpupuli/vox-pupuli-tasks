# enable logging to elasticsearch
SemanticLogger.add_appender(
  appender: :elasticsearch,
  url:      Rails.application.credentials.elasticsearch[:host]
)
