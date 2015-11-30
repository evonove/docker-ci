FROM ubuntu:15.10
MAINTAINER Emanuele Palazzetti <hello@palazzetti.me>

# set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# global environment
ENV TINI_VERSION v0.8.4
ENV JENKINS_HOME /var/jenkins_home

# python environment
ENV PYTHONZ_VERSION 1.10.0
ENV PYTHONZ_PATH /usr/local/pythonz
ENV PYTHONZ_EXEC $PYTHONZ_PATH/bin/pythonz
ENV PYTHON_PIP_VERSION 7.1.2
ENV TOX_VERSION 2.2.1

# using the installed versions instead of the system python
ENV PYTHON27_VERSION 2.7.10
ENV PYTHON34_VERSION 3.4.3
ENV PYTHON35_VERSION 3.5.0
ENV PATH $PYTHONZ_PATH/pythons/CPython-$PYTHON27_VERSION/bin:$PATH
ENV PATH $PYTHONZ_PATH/pythons/CPython-$PYTHON34_VERSION/bin:$PATH
ENV PATH $PYTHONZ_PATH/pythons/CPython-$PYTHON35_VERSION/bin:$PATH

# environment node
ENV NODE_VERSION 5.1.0
ENV NPM_VERSION 3.5.0
ENV NODE_PATH /usr/local/lib/node_modules/

# Update the system with build-in dependencies
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
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
       zlib1g-dev \
       libncurses5-dev \
       libgdbm-dev \
       libdb-dev \
       libexpat-dev \
       libpcap-dev \
       liblzma-dev \
       libpcre3-dev \
       curl \
       socat \
       postgresql-client \
       git \
       python-dev \
       python-pip \
       python3-dev \
       python3-pip \
       python3.5-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# creating jenkins user
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

# using tini as a zombies processes reaper
ENV TINI_SHA c4894d809f3e2bdcc9c2e20db037d80b17944fc6
RUN curl -fL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" -o /bin/tini \
  && chmod +x /bin/tini \
  && echo "$TINI_SHA /bin/tini" | sha1sum -c -
# tox
RUN python -m pip install -U pip \
  && python -m pip install tox==$TOX_VERSION

# frontend toolchain (node)
RUN gpg --keyserver pgp.mit.edu --recv-keys 114F43EE0176B71C7BC219DD50A3051F888C628D \
  && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && npm install -g npm@"$NPM_VERSION" \
  && npm install -g coffee-script gulp bower karma-cli phantomjs protractor \
  && npm cache clear

USER jenkins

# entrypoint required for Jenkins worker
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/bin/tini", "--", "/docker-entrypoint.sh"]
