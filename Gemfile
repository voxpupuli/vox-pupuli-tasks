# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rack', github: 'rack/rack', ref: 'f690bb71425aa31d7b9b3113829af773950d8ab5'

gem 'execjs'
gem 'puma', '~> 3.12'
gem 'rails', '~> 6.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'

gem 'chartkick'
gem 'fomantic-ui-sass', '2.8.4'
gem 'haml-rails'
gem 'react-rails'
gem 'redcarpet'

gem 'sidekiq', '~> 5.0'
gem 'sidekiq-scheduler'

gem 'sentry-raven'

gem 'jquery-datatables'
gem 'jquery-rails'

gem 'kaminari'

gem 'rails-settings-cached', '~> 2.0'

gem 'groupdate'

gem 'oj'
gem 'redis'

gem 'puppet_forge'

gem 'puppet_metadata', '~> 0.1'

gem 'octokit'
gem 'omniauth-github'

gem 'lograge'

gem 'bootsnap', '>= 1.1.0', require: false

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
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry-rails'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'travis'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'chromedriver-helper'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'selenium-webdriver'
end
