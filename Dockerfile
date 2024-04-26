FROM ruby:3.2.2-alpine

ENV NODE_ENV production
ENV RAILS_ENV production

RUN apk --no-cache update && apk --no-cache upgrade
RUN apk add --no-cache build-base linux-headers git nodejs yarn tzdata postgresql-dev postgresql-client shared-mime-info

RUN mkdir /vpt
WORKDIR /vpt
ADD . /vpt

RUN gem install bundler \
  && bundle config set deployment 'true' \
  && bundle config set path 'vendor/bundle' \
  && bundle config set without 'development test'

RUN bundle install --jobs $(nproc)
RUN SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rails assets:precompile
RUN date +%s > BUILD_DATE
