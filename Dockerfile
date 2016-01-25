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
ENV PYTHONZ_VERSION 1.11.0
ENV PYTHONZ_PATH /usr/local/pythonz
ENV PYTHONZ_EXEC $PYTHONZ_PATH/bin/pythonz
ENV PYTHON_PIP_VERSION 8.0.2
ENV TOX_VERSION 2.3.1

# using the installed versions instead of the system python
ENV PYTHON27_VERSION 2.7.10
ENV PYTHON34_VERSION 3.4.4
ENV PYTHON35_VERSION 3.5.1
ENV PATH $JENKINS_HOME/.local/bin:$PATH

# environment node
ENV NODE_VERSION 5.5.0
ENV NPM_VERSION 3.5.3
ENV NODE_PATH /usr/local/lib/node_modules/

# Update the system with build-in dependencies
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
       build-essential \
       git \
       autoconf \
       curl \
       socat \
       libcairo2 \
       libpango1.0-0 \
       libgdk-pixbuf2.0-0 \
       libffi-dev \
       libbz2-dev \
       libcurl4-openssl-dev \
       libevent-dev \
       libffi-dev \
       libglib2.0-dev \
       libjpeg-dev \
       libmagickcore-dev \
       libmagickwand-dev \
       libmysqlclient-dev \
       libncurses5-dev \
       libpq-dev \
       libreadline-dev \
       libsqlite3-dev \
       libssl-dev \
       libxml2-dev \
       libxslt1-dev \
       libyaml-dev \
       libncurses5-dev \
       libgdbm-dev \
       libdb-dev \
       libexpat1-dev \
       libpcap-dev \
       liblzma-dev \
       libpcre3-dev \
       postgresql-client \
       imagemagick \
       shared-mime-info \
       zlib1g-dev \
       python-lxml \
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

# installing python requirements
RUN pip install -U pip=="$PYTHON_PIP_VERSION" \
  && pip install tox=="$TOX_VERSION"

# installing python interpreters
RUN curl -fL "https://raw.githubusercontent.com/saghul/pythonz/pythonz-$PYTHONZ_VERSION/pythonz-install" | bash \
  && $PYTHONZ_EXEC install $PYTHON27_VERSION \
  && $PYTHONZ_EXEC install $PYTHON34_VERSION \
  && $PYTHONZ_EXEC install $PYTHON35_VERSION \
  && rm -rf $PYTHONZ_PATH/build/* \
  && rm -rf $PYTHONZ_PATH/dists/* \
  && rm -rf $PYTHONZ_PATH/log/* \
  && find $PYTHONZ_PATH/pythons -name '*.pyc' -delete \
  && find $PYTHONZ_PATH/pythons -name '*.pyo' -delete \
  && mkdir -p $JENKINS_HOME/.local/bin \
  && ln -s $PYTHONZ_PATH/pythons/CPython-$PYTHON27_VERSION/bin/python2.7 $JENKINS_HOME/.local/bin/python2.7 \
  && ln -s $PYTHONZ_PATH/pythons/CPython-$PYTHON34_VERSION/bin/python3.4 $JENKINS_HOME/.local/bin/python3.4 \
  && ln -s $PYTHONZ_PATH/pythons/CPython-$PYTHON35_VERSION/bin/python3.5 $JENKINS_HOME/.local/bin/python3.5

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

# frontend toolchain (node)
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
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
