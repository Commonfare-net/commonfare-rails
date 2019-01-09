FROM ruby:2.4
MAINTAINER pbmolini@fbk.eu

# Download all the dependencies including node and yarn. Also, set localtime
# TODO: do this also in staging and production
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -qq -y --no-install-recommends build-essential nodejs yarn cron \
    && rm -rf /var/lib/apt/lists/* \
    && cp /usr/share/zoneinfo/Europe/Rome /etc/localtime

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app
WORKDIR /app

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"
# Bundle installs with binstubs to our custom /bundle/bin volume path. Let system use those stubs.

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
    && bundle install --jobs 20 --retry 5

# Copy the main application.
COPY . ./

# RUN bin/yarn

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# Entrypoint
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

RUN bundle exec whenever --update-crontab --set environment=development
CMD cron && bundle exec puma
