# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set development environment by default
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"



# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems and Oracle Instant Client
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libvips \
    pkg-config \
    wget \
    libaio1 \
    alien \
    && rm -rf /var/lib/apt/lists/*

# Install Oracle Instant Client
RUN mkdir -p /opt/oracle && \
    cd /opt/oracle && \
    wget https://download.oracle.com/otn_software/linux/instantclient/2113000/oracle-instantclient-basic-21.13.0.0.0-1.el8.x86_64.rpm && \
    wget https://download.oracle.com/otn_software/linux/instantclient/2113000/oracle-instantclient-devel-21.13.0.0.0-1.el8.x86_64.rpm && \
    alien -i oracle-instantclient-basic-21.13.0.0.0-1.el8.x86_64.rpm && \
    alien -i oracle-instantclient-devel-21.13.0.0.0-1.el8.x86_64.rpm && \
    rm -f *.rpm

# Set Oracle environment variables
ENV LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib:$LD_LIBRARY_PATH \
    PATH=/usr/lib/oracle/21/client64/bin:$PATH \
    ORACLE_HOME=/usr/lib/oracle/21/client64

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/


# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libvips \
    libaio1 \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy Oracle Instant Client from build stage
COPY --from=build /usr/lib/oracle /usr/lib/oracle

# Set Oracle environment variables
ENV LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib:$LD_LIBRARY_PATH \
    PATH=/usr/lib/oracle/21/client64/bin:$PATH \
    ORACLE_HOME=/usr/lib/oracle/21/client64

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
