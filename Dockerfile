FROM ruby:2.7-alpine

ENV NODE_ENV production
ENV RAILS_ENV production

RUN apk update && apk upgrade
RUN apk add build-base linux-headers git nodejs yarn tzdata postgresql-dev postgresql-client

RUN mkdir /vpt
WORKDIR /vpt
ADD . /vpt

RUN git describe --always > VERSION

RUN gem install bundler
RUN bundle config set deployment 'true'
RUN bundle config set path 'vendor/bundle'
RUN bundle config set without 'development test'
RUN bundle install --jobs $(nproc)
RUN SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rails assets:precompile
RUN date +%s > BUILD_DATE
