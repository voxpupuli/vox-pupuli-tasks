# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rack'

gem 'execjs'
gem 'puma', '~> 4.3'
gem 'rails', '~> 6.1.4'
gem 'sass-rails', '~> 6.0'
gem 'uglifier', '>= 1.3.0'

gem 'coffee-rails', '~> 5.0'
gem 'jbuilder', '~> 2.5'

gem 'chartkick'
gem 'fomantic-ui-sass', '2.8.7'
gem 'haml-rails'
gem 'react-rails'
gem 'redcarpet'

gem 'sidekiq', '~> 6.0'
gem 'sidekiq-scheduler'

gem 'sentry-ruby'

gem 'jquery-datatables'
gem 'jquery-rails'

gem 'kaminari'

gem 'rails-settings-cached', '~> 2.0'

gem 'groupdate'

gem 'oj'
gem 'redis'

gem 'puppet_forge'

gem 'octokit'
gem 'omniauth-github'

gem 'lograge'

gem 'bootsnap', '>= 1.1.0', require: false

gem 'opentelemetry-api'
gem 'opentelemetry-exporter-jaeger'
gem 'opentelemetry-instrumentation-pg'
gem 'opentelemetry-instrumentation-rails'
gem 'opentelemetry-instrumentation-sidekiq'
gem 'opentelemetry-sdk'

group :production do
  gem 'pg'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # provides colorized log output on the CLI (ANSI color codes)
  gem 'awesome_print'
  gem 'sqlite3'
end

group :development do
  gem 'foreman'
  gem 'haml-lint'
  gem 'irb'
  gem 'listen'
  gem 'pry-rails'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'chromedriver-helper'
  gem 'rubocop', '~> 1.18'
  gem 'rubocop-rails'
  gem 'selenium-webdriver'
end
