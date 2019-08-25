FROM ruby:alpine

ENV NODE_ENV production
ENV RAILS_ENV production

RUN apk update && apk upgrade
RUN apk add build-base linux-headers git nodejs yarn tzdata sqlite-dev

RUN mkdir /vpt
WORKDIR /vpt
ADD . /vpt

RUN git describe --always > VERSION

RUN gem install bundler
RUN bundle install --jobs $(nproc) --without development test --path vendor/bundle --deployment
RUN SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rails assets:precompile
RUN date +%s > BUILD_DATE
