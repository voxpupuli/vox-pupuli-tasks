FROM ruby:alpine

RUN apk update && apk upgrade
RUN apk add build-base linux-headers git nodejs yarn tzdata

RUN mkdir /vpt
WORKDIR /vpt
ADD . /vpt

RUN git describe --always > VERSION

RUN gem install bundler
RUN bundle install --jobs $(nproc) --without development test --path vendor/bundle --deployment
RUN NODE_ENV=production bundle exec yarn install --frozen-lockfile --non-interactive
RUN NODE_ENV=production RAILS_ENV=production bundle exec rails assets:precompile
RUN data +%s > BUILD_DATE
