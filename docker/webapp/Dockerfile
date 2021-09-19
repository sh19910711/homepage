FROM ruby:2.7.4

ADD ./Gemfile /tmp
WORKDIR /tmp
RUN bundle install -j4 --without development

RUN mkdir /wrk
ADD ./app /wrk
ADD ./config.ru /wrk
ADD ./data /wrk
WORKDIR /wrk

ENV RACK_ENV=production
EXPOSE 8080
CMD bundle exec rackup --host 0.0.0.0 --port 8080
