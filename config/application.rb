# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

OpenTelemetry::SDK.configure do |c|
  require 'pg'
  c.use 'OpenTelemetry::Instrumentation::PG'
  c.use 'OpenTelemetry::Instrumentation::Rails'
  c.use 'OpenTelemetry::Instrumentation::Sidekiq'

  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::Jaeger::AgentExporter.new(host: '127.0.0.1', port: 6831)
      # Alternatively, for the collector exporter:
      # exporter: OpenTelemetry::Exporter::Jaeger::CollectorExporter.new(endpoint: 'http://192.168.0.1:14268/api/traces')
    )
  )
end

module VoxPupuliTasks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    # config.autoload_paths += %W(#{config.root}/lib)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    if Rails.application.credentials.sentry
      Sentry.init do |config|
        config.dsn = Rails.application.credentials.sentry[Rails.env.to_sym]
      end
    end
  end
end
