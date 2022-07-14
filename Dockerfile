FROM ruby:latest

RUN apt-get install -y default-libmysqlclient-dev

WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .

ENV RAILS_ENV production