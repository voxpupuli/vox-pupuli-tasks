# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rack'

gem 'execjs'
gem 'puma', '~> 5.6'

gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false
gem 'rails', '~> 6.1.6'

gem 'sass-rails', '~> 6.0'
gem 'uglifier', '>= 1.3.0'

gem 'coffee-rails', '~> 5.0'
gem 'jbuilder', '~> 2.11'

gem 'chartkick'
gem 'fomantic-ui-sass', '2.8.8'
gem 'haml-rails'
gem 'react-rails'
gem 'redcarpet'

gem 'sidekiq', '< 6'
gem 'sidekiq-scheduler'

gem 'sentry-raven'

gem 'jquery-datatables'
gem 'jquery-rails'

gem 'kaminari'

gem 'rails-settings-cached', '~> 2.8'

gem 'groupdate'

gem 'oj'
gem 'redis'

gem 'puppet_forge'

gem 'puppet_metadata', '~> 1.7'

gem 'octokit'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'

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
  gem 'rubocop', '~> 1.30'
  gem 'rubocop-rails'
  gem 'selenium-webdriver'
end

group :release do
  gem 'github_changelog_generator', require: false
end
