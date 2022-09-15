FROM ruby:3.1.2-slim AS base

RUN apt-get update; \
	apt-get install -y --no-install-recommends \
#		bison \
#		dpkg-dev \
#		libgdbm-dev \
#		ruby \
#		autoconf \
		g++ \
		gcc \
#		libbz2-dev \
#		libgdbm-compat-dev \
#		libglib2.0-dev \
#		libncurses-dev \
#		libreadline-dev \
#		libxml2-dev \
#		libxslt-dev \
		make \
#		wget \
#		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

# Install gems (excluding development/test dependencies)
RUN bundle config set without "development test" && \
  bundle install --jobs=3 --retry=3

# We're back at the base stage
FROM base

# Create a non-root user to run the app and own app-specific files
RUN adduser app

# Switch to this user
USER app

# We'll install the app in this directory
WORKDIR /home/app

# Copy over gems from the base stage
COPY --from=base /usr/local/bundle/ /usr/local/bundle/

# Finally, copy over the code
# This is where the .dockerignore file comes into play
# Note that we have to use `--chown` here
COPY --chown=app . ./

CMD [ "script/server" ]
EXPOSE 9292
