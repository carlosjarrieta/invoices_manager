# syntax = docker/dockerfile:1
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim

WORKDIR /rails

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libvips \
    pkg-config \
    wget \
    unzip \
    libaio1 \
    curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Oracle Instant Client
RUN mkdir -p /opt/oracle && \
    cd /opt/oracle && \
    wget -q https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip && \
    wget -q https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-sdk-linux.x64-21.12.0.0.0dbru.zip && \
    unzip -q instantclient-basic-linux.x64-21.12.0.0.0dbru.zip && \
    unzip -q instantclient-sdk-linux.x64-21.12.0.0.0dbru.zip && \
    rm *.zip

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_21_12

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

