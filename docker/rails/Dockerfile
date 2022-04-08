ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}

SHELL ["/bin/bash", "-c"]

RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential curl openssh-client \
    default-libmysqlclient-dev tzdata vim \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ENV LANG=C.UTF-8

RUN echo "gem: --no-document" > /usr/local/etc/gemrc
RUN gem update --system && gem install bundle

WORKDIR /sleep_tracker
COPY Gemfile Gemfile.lock /sleep_tracker/
RUN bundle install
