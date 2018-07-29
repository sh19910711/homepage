FROM ruby:2.5.1-alpine

ADD Gemfile /wrk/Gemfile
ADD Gemfile.lock /wrk/Gemfile.lock
WORKDIR /wrk
RUN apk update && \
  apk add build-base libffi-dev && \
  bundle install -j4 --without development

ENV RACK_ENV=production

ADD ./homepage /wrk/homepage
ADD ./lib /wrk/lib
ADD ./config.ru /wrk

EXPOSE 8080
CMD bundle exec rackup --host 0.0.0.0 --port 8080
