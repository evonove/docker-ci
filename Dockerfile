FROM ubuntu:14.10
MAINTAINER Evonove info@evonove.it

# Environment variables
ENV TOX_VERSION 1.9.1
ENV NODE_VERSION 0.12.0
ENV NODE_PATH /usr/local/lib/node_modules/
ENV NPM_VERSION 2.5.1

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

# Python with latest 'pip' and 'tox'
RUN apt-get install -y python-dev python-pip python3-dev python3-pip
RUN python -m pip install -U pip
RUN python -m pip install tox==$TOX_VERSION

# Frontend toolchain
RUN apt-get install -y ruby ruby-dev
RUN gem install compass

RUN gpg --keyserver pgp.mit.edu --recv-keys 114F43EE0176B71C7BC219DD50A3051F888C628D

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
