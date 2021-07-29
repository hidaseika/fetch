FROM ruby:2.7.4

WORKDIR /usr/src/fetch
COPY . .

RUN bundle update --bundler
RUN bundle install
