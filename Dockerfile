FROM ruby:2.7.4

ADD ./Gemfile /tmp
WORKDIR /tmp
RUN bundle install -j4 --without development

RUN mkdir /wrk
ADD ./app /wrk/app
ADD ./config.ru /wrk/
ADD ./Gemfile* /wrk/
ADD ./data /wrk/data
WORKDIR /wrk

ENV RACK_ENV=production
CMD bundle exec rackup --host 0.0.0.0 --port $PORT
