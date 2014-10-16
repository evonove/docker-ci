FROM ubuntu:14.04
MAINTAINER Evonove info@evonove.it

# Environment variables
ENV NODE_VERSION 0.10.32
ENV NPM_VERSION 2.1.3

# Update system libraries
RUN apt-get update && apt-get upgrade -y

# Install all build requirements
RUN apt-get install -y \
    autoconf \
    build-essential \
    imagemagick \
    libbz2-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libffi-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libmysqlclient-dev \
    libncurses-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    zlib1g-dev

# Other requirement
RUN apt-get install -y curl socat postgresql-client

# VCS
RUN apt-get install -y git

# Python
RUN apt-get install -y python-dev python-pip python3-dev python3-pip

# Frontend toolchain
RUN apt-get install -y ruby ruby-dev
RUN gem install compass

RUN gpg --keyserver pgp.mit.edu --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && npm install -g npm@"$NPM_VERSION"

RUN npm install -g coffee-script gulp bower karma-cli phantomjs protractor

# Clean everything
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && npm cache clear
