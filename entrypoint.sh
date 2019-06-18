#!/bin/sh
bundle exec rails db:migrate
bundle exec rails s -b '0.0.0.0'
